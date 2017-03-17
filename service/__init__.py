# -*- coding: utf-8 -*-
from flask import Flask, current_app, request, jsonify
import io
import base64
import logging
import numpy as np
import cv2
from google.cloud import error_reporting
import google.cloud.logging
from service import model

def create_app(config, debug=False, testing=False, config_overrides=None):

    app = Flask(__name__)
    app.config.from_object(config)

    if config_overrides:
        app.config.update(config_overrides)

     # Configure logging
    if not app.testing:
        client = google.cloud.logging.Client(app.config['PROJECT_ID'])
        # Attaches a Google Stackdriver logging handler to the root logger
        client.setup_logging(logging.INFO)

    # Create a health check handler. Health checks are used when running on
    # Google Compute Engine by the load balancer to determine which instances
    # can serve traffic. Google App Engine also uses health checking, but
    # accepts any non-500 response as healthy.
    @app.route('/_ah/health')
    def health_check():
        return 'ok', 200

    @app.route('/', methods=['POST'])
    def predict():
        data = {}
        try:
            data = request.get_json()['data']
        except Exception:
            return jsonify(status_code='400', msg='Bad Request'), 400

        image = io.BytesIO(base64.b64decode(data))
        img = cv2.imdecode(np.fromstring(image.getvalue(), dtype=np.uint8), 1)

        response = {}
        prediction = model.predict(img)
        if prediction == 0:
            response['prediction'] = 'boss'
        else:
            response['prediction'] = 'other'

        current_app.logger.info('Prediction: %s', prediction)
        return jsonify(response)

    # Add an error handler that reports exceptions to Stackdriver Error
    # Reporting. Note that this error handler is only used when Debug
    # is False
    @app.errorhandler(500)
    def server_error(e):
        client = error_reporting.Client(app.config['PROJECT_ID'])
        client.report_exception(
            http_context=error_reporting.build_flask_context(request))
        return """
        An internal error occurred.
        """, 500

    return app

# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=8080, debug=True)
