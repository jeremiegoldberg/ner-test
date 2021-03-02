
FROM huggingface/transformers-pytorch-cpu

RUN pip3 install sentencepiece protobuf

COPY . ./

RUN python3 download.py

CMD ["python3", "test.py"]
