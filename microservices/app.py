from fastapi import FastAPI, HTTPException
import requests

app = FastAPI()

BASE_URL = "https://api.open-meteo.com/v1/forecast"

from flask import Flask, request, jsonify, send_from_directory

app = Flask(__name__)

@app.route('/')
def serve_index():
    return send_from_directory('.', 'index.html')

@app.get("/weather")
def get_weather(lat: float, lon: float):
    """
    Fetch current weather for the given latitude and longitude.
    """
    params = {
        "latitude": lat,
        "longitude": lon,
        "current_weather": True
    }
    try:
        response = requests.get(BASE_URL, params=params)
        response.raise_for_status()
        data = response.json()
        return {
            "latitude": lat,
            "longitude": lon,
            "current_weather": data.get("current_weather", {})
        }
    except requests.RequestException as e:
        raise HTTPException(status_code=500, detail=str(e))
