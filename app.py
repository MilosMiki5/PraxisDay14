from flask import Flask

app = Flask(__name__)


@app.route('/')
def hello_world():
    """Simple hello world endpoint."""
    return 'Hello!', 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)