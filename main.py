import os
from flask import Flask, request, render_template
from text_to_dys import process_text_to_dys

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        text = request.form['text']
        result = process_text_to_dys(text)
        return render_template('index.html', text=text, result=result)
    return render_template('index.html', text=None, result=None)

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
