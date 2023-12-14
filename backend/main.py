# main.py

from flask import Flask, request, jsonify
from flask_cors import CORS
from recommenders import Recommender
import json

app = Flask(__name__)
CORS(app)
recommender = Recommender("./content-based-filtering-model_light_v1.0.joblib")

@app.route('/recommend', methods=['GET'])
def recommend():
    user_id = request.args.get('user_id', type=int)
    topn = request.args.get('topn', default=5, type=int)

    if user_id is None:
        return jsonify({'error': 'user_id is required'}), 400

    try:
        recommendations = recommender.top_recommendations(user_id, topn=topn)
        response_data = {'recommendations': recommendations}
        jsonified = json.dumps(response_data)
        return jsonified
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
