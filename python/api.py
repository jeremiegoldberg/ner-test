import json
import uvicorn
import prometheus_client as prom
from prometheus_client import Counter, generate_latest
from fastapi import FastAPI, Request, Response
from pydantic import BaseModel
from transformers import pipeline
from transformers import AutoTokenizer, AutoModelForTokenClassification

tokenizer = AutoTokenizer.from_pretrained("gilf/french-camembert-postag-model")
model = AutoModelForTokenClassification.from_pretrained("gilf/french-camembert-postag-model")

nlp_token_class = pipeline('ner', model=model, tokenizer=tokenizer, grouped_entities=True)

class JsonRequest(BaseModel):
    text: str

app = FastAPI()

totalcount = Counter('app.wordclass-api.num_requests', 'The number of requests.')

@app.get("/metrics")
async def metrics():
    return Response(generate_latest())


@app.post("/")
async def root(data: JsonRequest):
#    try:
        Dict = {}
        List = []

        result = nlp_token_class(data.text)
        #callback = json.dumps(result)

        for i in result:
          if i["entity_group"] == "NPP":
             List.append(i["word"])

        Dict["NPP"] = List

        print(type(result))
        print(type(data))

        #callback = json.loads(result)[0]

        totalcount.inc()

        return Dict

#    except:
#        return {'message': 'input error'}, 400


if __name__ == "__main__":
    uvicorn.run("api:app")
