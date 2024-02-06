# Clone repo
```bash 
git clone https://github.com/aniruddhapal211316/brouhaha-vad.git
cd brouhaha-vad
```

# Dataset description
The directory name of the dataset should be `dataset` and should following the below directory structure : 
```
dataset/
|── train/
|   ├── audio_16k
|   │   └── file_1.flac
|   │   └── ...
|   ├── detailed_snr_labels
|   │   └── file_1_snr.npy
|   │   └── ...
|   ├── reverb_labels.txt
|   └── rttm_files
|       └── file_1.rttm
|       └── ...
|── dev/
|   ├── audio_16k
|   │   └── file_1.flac
|   │   └── ...
|   ├── detailed_snr_labels
|   │   └── file_1_snr.npy
|   │   └── ...
|   ├── reverb_labels.txt
|   └── rttm_files
|       └── file_1.rttm
|       └── ...
└── test/
    ├── audio_16k
    │   └── file_1.flac
    │   └── ...
    ├── detailed_snr_labels
    │   └── file_1_snr.npy
    │   └── ...
    ├── reverb_labels.txt
    └── rttm_files
        └── file_1.rttm
        └── ...
```


# Docker image build 
```bash
docker build -t brouhaha-vad --rm .
```

# Run docker container : brouhaha-vad
```bash
docker run --name brouhaha -it --rm --gpus all --shm-size 16G -v ~/brouhaha_volume/:/workspace/volume/ brouhaha-vad bash
```

Here `~/brouhaha_volume/` of local is mounted as `/workspace/volume/` in docker container. In `~/brouhaha_volume/` directory the `dataset` is present which will be accessible inside the docker container. From docker container we should store the inference data and performance metrics in `/workspace/volume/` which will be accessible from `~/brouhaha_volume/` in local. The reason for this mounting is to make our dataset accessible inside docker container, also to store the infernce data and performance metrics permanently in local storage even when the docker container is destroyed. 

# Copy config.yaml
```bash
cp -r  experiment/ volume/
```
The experiment directory contains the `conf.yaml` file which is the configuration file for our model. The `experiment` directory will contain all the trained models and hyperparameter configurations after training, thus we will move it to `/workspace/volume/` directory so that we can access all the trained model and hyperparameter configurations permanently in local storage at `~/brouhaha_volume/` even when the docker container is destroyed.

# Train 
```bash
python3 brouhaha/main.py train volume/experiment/ -p Brouhaha.SpeakerDiarization.NoisySpeakerDiarization --model_type pyannet --epoch 35 --data_dir volume/dataset/
```

# Tune 
```bash
python3 brouhaha/main.py tune volume/experiment/ -p Brouhaha.SpeakerDiarization.NoisySpeakerDiarization --model_path volume/experiment/checkpoints/last.ckpt --data_dir volume/dataset/ --params volume/experiment/VADTest/hparams.yaml
```

# Inference 
```bash
python3 brouhaha/main.py apply -p Brouhaha.SpeakerDiarization.NoisySpeakerDiarization --model_path volume/experiment/checkpoints/last.ckpt --data_dir volume/dataset/ --out_dir volume/dataset/inference/ --ext wav --params volume/experiment/VADTest/hparams.yaml
```

# Score 
```bash
python3 brouhaha/main.py score -p Brouhaha.SpeakerDiarization.NoisySpeakerDiarization --model_path volume/experiment/checkpoints/last.ckpt --data_dir volume/dataset/ --out_dir volume/dataset/inference/ --report_path volume/metrics_score/
```