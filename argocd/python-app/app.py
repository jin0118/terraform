import os
from flask import Flask

app = Flask(__name__)

@app.route("/")
def hello():
    ecr_image = os.environ.get("ECR_IMAGE", "unknown")
    return f"Hello, World {ecr_image}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
