import json
import uvicorn

from transformers import AutoTokenizer, AutoModelForTokenClassification

tokenizer = AutoTokenizer.from_pretrained("gilf/french-camembert-postag-model")
model = AutoModelForTokenClassification.from_pretrained("gilf/french-camembert-postag-model")

from transformers import pipeline

nlp_token_class = pipeline('ner', model=model, tokenizer=tokenizer, grouped_entities=True)

from fastapi import FastAPI, Request
from pydantic import BaseModel

class JsonRequest(BaseModel):
    text: str

app = FastAPI()

#@app.post("/people")
#async def getNames():
#    result = json.loads(nlp_token_class(request.json["text"]))

#    for key in result:
#      print(key)

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

        return Dict

#    except:
#        return {'message': 'input error'}, 400


if __name__ == "__main__":
    uvicorn.run("api:app")
