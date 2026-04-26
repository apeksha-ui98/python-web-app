from flask import Flask, send_from_directory


app = Flask(__name__)


@app.route("/home")
def home():
    return send_from_directory("static", "home.html")


@app.route("/courses")
def courses():
    return send_from_directory("static", "courses.html")


@app.route("/about")
def about():
    return send_from_directory("static", "about.html")


@app.route("/contact")
def contact():
    return send_from_directory("static", "contact.html")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)