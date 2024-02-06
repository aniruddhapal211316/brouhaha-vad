FROM pytorch/pytorch:1.13.1-cuda11.6-cudnn8-runtime

WORKDIR /workspace/
COPY . .
COPY database.yml /root/.pyannote/
RUN apt update
RUN apt install -y git
RUN pip install pyannote.audio==2.1.1
RUN pip install git+https://github.com/marianne-m/pyannote-brouhaha-db.git
RUN pip install .
RUN pip install pyarrow==15.0.0
RUN pip uninstall -y torchaudio
RUN pip install torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116
RUN apt install -y libsndfile1=1.0.28-4ubuntu0.18.04.2