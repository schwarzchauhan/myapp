"""City search server — returns top 3 closest matches for a query."""

from __future__ import annotations

import json
from difflib import SequenceMatcher
from pathlib import Path

from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

CITIES_PATH = Path(__file__).with_name("cities.json")


def load_cities() -> list[dict]:
    with CITIES_PATH.open(encoding="utf-8") as f:
        return json.load(f)


CITIES = load_cities()


def score_city(query: str, city: dict) -> float:
    """Similarity score in [0, 1]. Exact code match ranks highest."""
    q = query.strip().lower()
    if not q:
        return 0.0

    name = city["name"].lower()
    code = city["code"].lower()
    country = city.get("country", "").lower()

    if q == code:
        return 1.0
    if q == name:
        return 0.99
    if name.startswith(q) or code.startswith(q):
        return 0.95
    if q in name or q in code:
        return 0.85

    name_score = SequenceMatcher(None, q, name).ratio()
    code_score = SequenceMatcher(None, q, code).ratio()
    country_score = SequenceMatcher(None, q, country).ratio() * 0.5
    return max(name_score, code_score, country_score)


@app.get("/health")
def health():
    return jsonify({"status": "ok", "cities": len(CITIES)})


@app.get("/search")
def search():
    query = (request.args.get("q") or "").strip()
    if not query:
        return jsonify({"error": "Missing query param 'q'"}), 400

    ranked = sorted(
        ({**city, "score": round(score_city(query, city), 4)} for city in CITIES),
        key=lambda c: c["score"],
        reverse=True,
    )
    top3 = [c for c in ranked[:3] if c["score"] > 0]
    return jsonify({"query": query, "results": top3})


@app.post("/search")
def search_post():
    body = request.get_json(silent=True) or {}
    query = (body.get("query") or body.get("q") or "").strip()
    if not query:
        return jsonify({"error": "Missing 'query' in JSON body"}), 400

    ranked = sorted(
        ({**city, "score": round(score_city(query, city), 4)} for city in CITIES),
        key=lambda c: c["score"],
        reverse=True,
    )
    top3 = [c for c in ranked[:3] if c["score"] > 0]
    return jsonify({"query": query, "results": top3})


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5050, debug=True)


# python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && python server.py