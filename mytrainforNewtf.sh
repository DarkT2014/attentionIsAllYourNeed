#!/usr/bin/env bash

DATA_DIR="/tmp/t2t_datagen"
PARAM_SET="base"
MODEL_DIR="model_dir/model_subword_4096_$PARAM_SET"

# SOURCE_DIR=./test_data/source_data
# INPUT_VOCAB="$DATA_DIR/en_sub_word.vocab"
# TARGET_VOCAB="$DATA_DIR/zh_sub_word.vocab"
echo "Pythonpath is :"
echo $PYTHONPATH
export PYTHONPATH="$PYTHONPATH:$PWD/models"
PARAM_BATCH="batch_size=16"

echo $PYTHONPATH
pip install --user -r models/official/requirements.txt
# export PYTHONPATH="$PYTHONPATH:${PWD}/models"
# cat "${DATA_DIR}/en_sub_word.vocab" \
#     "${DATA_DIR}/zh_sub_word.vocab" \
#   > "${DATA_DIR}/enzhfornewtf.vocab"
# VOCAB_FILE=$DATA_DIR/enzh.vocab
VOCAB_FILE="/tmp/t2t_datagen/enzh.vocab"
echo "\n The vocab file path is \n"
echo $VOCAB_FILE

python models/official/transformer/transformer_main.py --data_dir=$DATA_DIR --model_dir=$MODEL_DIR  --vocab_file=$VOCAB_FILE --param_set=base
    

    # --param_set=$PARAM_SET