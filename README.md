# prediction

## Test with curl

```sh
ENDPOINT=x.x.x.x

(echo -n '{"data": "'; base64 /location/to/test.jpg; echo '"}') |
curl -X POST -H "Content-Type: application/json" -d @- http://$ENDPOINT:8080/predict
```
