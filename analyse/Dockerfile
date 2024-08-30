FROM python:3.8-slim

WORKDIR /work

COPY . /work/

RUN pip install -r requirements.txt

EXPOSE 8888

CMD [ "jupyter", "notebook", "--ip=0.0.0.0", "--p=8888", "--no-browser", "--allow-root", "--notebook-dir=/work"]