import service
import config

app = service.create_app(config)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
