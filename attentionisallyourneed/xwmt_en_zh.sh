#! /usr/bin/env bash

# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"
BASE_DIR="seq2seq/"

# OUTPUT_DIR=${OUTPUT_DIR:-$HOME/nmt_data/wmt16_zh_en}
# echo "Writing to ${OUTPUT_DIR}. To change this, set the OUTPUT_DIR environment variable."

OUTPUT_DIR="/tmp/t2t_datagen"


OUTPUT_DIR_DATA="${OUTPUT_DIR}/data"

mkdir -p $OUTPUT_DIR_DATA

echo "Downloading cwmt file . This may take a while ..."
wget -nc -P ${OUTPUT_DIR_DATA} https://s3-us-west-2.amazonaws.com/twairball.wmt17.zh-en/cwmt.tgz || gsutil cp gs://darkt_data/cwmt.tgz ${OUTPUT_DIR_DATA} || echo "download fail, try to find localfile."

echo "unzipping cwmt file"
tar -zxvf "${OUTPUT_DIR_DATA}/cwmt.tgz" -C "${OUTPUT_DIR_DATA}"

echo "unzipping dev and test file .."
tar -zxvf "${HOME}/dev.tgz" -C "${OUTPUT_DIR_DATA}"
tar -zxvf "${HOME}/test.tgz" -C "${OUTPUT_DIR_DATA}"

# echo "Downloading Europarl v7. This may take a while..."
# wget -nc -nv -O ${OUTPUT_DIR_DATA}/europarl-v7-zh-en.tgz \
#   http://www.statmt.org/europarl/v7/zh-en.tgz

# echo "Downloading Common Crawl corpus. This may take a while..."
# wget -nc -nv -O ${OUTPUT_DIR_DATA}/common-crawl.tgz \
#   http://www.statmt.org/wmt13/training-parallel-commoncrawl.tgz

# echo "Downloading News Commentary v11. This may take a while..."
# wget -nc -nv -O ${OUTPUT_DIR_DATA}/nc-v11.tgz \
#   http://data.statmt.org/wmt16/translation-task/training-parallel-nc-v11.tgz

# echo "Downloading dev/test sets"
# wget -nc -nv -O  ${OUTPUT_DIR_DATA}/dev.tgz \
#   http://data.statmt.org/wmt16/translation-task/dev.tgz
# wget -nc -nv -O  ${OUTPUT_DIR_DATA}/test.tgz \
#   http://data.statmt.org/wmt16/translation-task/test.tgz

# # Extract everything
# echo "Extracting all files..."
# mkdir -p "${OUTPUT_DIR_DATA}/europarl-v7-zh-en"
# tar -xvzf "${OUTPUT_DIR_DATA}/europarl-v7-zh-en.tgz" -C "${OUTPUT_DIR_DATA}/europarl-v7-zh-en"
# mkdir -p "${OUTPUT_DIR_DATA}/common-crawl"
# tar -xvzf "${OUTPUT_DIR_DATA}/common-crawl.tgz" -C "${OUTPUT_DIR_DATA}/common-crawl"
# mkdir -p "${OUTPUT_DIR_DATA}/nc-v11"
# tar -xvzf "${OUTPUT_DIR_DATA}/nc-v11.tgz" -C "${OUTPUT_DIR_DATA}/nc-v11"
# mkdir -p "${OUTPUT_DIR_DATA}/dev"
# tar -xvzf "${OUTPUT_DIR_DATA}/dev.tgz" -C "${OUTPUT_DIR_DATA}/dev"
# mkdir -p "${OUTPUT_DIR_DATA}/test"
# tar -xvzf "${OUTPUT_DIR_DATA}/test.tgz" -C "${OUTPUT_DIR_DATA}/test"

# Concatenate Training data
# cat "${OUTPUT_DIR_DATA}/cwmt/casia2015/casia2015_en.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/casict2015/casict2015_en.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/datum2015/datum_en.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/datum2017/Book1_en.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/neu2017/NEU_en.txt" \
#   > "${OUTPUT_DIR}/train.en"
cat "${OUTPUT_DIR_DATA}/cwmt/casia2015/casia2015_en.txt" \
  > "${OUTPUT_DIR}/train.en"
wc -l "${OUTPUT_DIR}/train.en"

# cat "${OUTPUT_DIR_DATA}/cwmt/casia2015/casia2015_ch.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/casict2015/casict2015_ch.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/datum2015/datum_ch.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/datum2017/Book1_cn.txt" \
#   "${OUTPUT_DIR_DATA}/cwmt/neu2017/NEU_cn.txt" \
#   > "${OUTPUT_DIR}/train.zh"
cat "${OUTPUT_DIR_DATA}/cwmt/casia2015/casia2015_ch.txt" \
  > "${OUTPUT_DIR}/train.zh"
wc -l "${OUTPUT_DIR}/train.zh"

# Clone Moses
if [ ! -d "${OUTPUT_DIR}/mosesdecoder" ]; then
  echo "Cloning moses for data processing"
  git clone https://github.com/moses-smt/mosesdecoder.git "${OUTPUT_DIR}/mosesdecoder"
fi

${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
  < ${OUTPUT_DIR_DATA}/dev/dev/newsdev2017-enzh-src.en.sgm \
  > ${OUTPUT_DIR_DATA}/dev/dev/newstest2017.en
${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
  < ${OUTPUT_DIR_DATA}/dev/dev/newstest2017-enzh-ref.zh.sgm \
  > ${OUTPUT_DIR_DATA}/dev/dev/newstest2017.zh

# # Convert newstest2015 data into raw text format
# ${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
#   < ${OUTPUT_DIR_DATA}/dev/dev/newstest2015-deen-src.de.sgm \
#   > ${OUTPUT_DIR_DATA}/dev/dev/newstest2015.de
# ${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
#   < ${OUTPUT_DIR_DATA}/dev/dev/newstest2015-deen-ref.en.sgm \
#   > ${OUTPUT_DIR_DATA}/dev/dev/newstest2015.en

# Convert newstest2016 data into raw text format
${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
  < ${OUTPUT_DIR_DATA}/test/test/newstest2018-enzh-src.en.sgm \
  > ${OUTPUT_DIR_DATA}/test/test/newstest2018.en
${OUTPUT_DIR}/mosesdecoder/scripts/ems/support/input-from-sgm.perl \
  < ${OUTPUT_DIR_DATA}/test/test/newstest2018-enzh-ref.zh.sgm \
  > ${OUTPUT_DIR_DATA}/test/test/newstest2018.zh

# Copy dev/test data to output dir
cp ${OUTPUT_DIR_DATA}/dev/dev/newstest20*.zh ${OUTPUT_DIR}
cp ${OUTPUT_DIR_DATA}/dev/dev/newstest20*.en ${OUTPUT_DIR}
cp ${OUTPUT_DIR_DATA}/test/test/newstest20*.zh ${OUTPUT_DIR}
cp ${OUTPUT_DIR_DATA}/test/test/newstest20*.en ${OUTPUT_DIR}



python prepare_data/jieba_cws.py $OUTPUT_DIR/train.zh > $OUTPUT_DIR/wmt_enzh_32768k_tok_train.lang1
python prepare_data/jieba_cws.py $OUTPUT_DIR/newstest2018.zh > $OUTPUT_DIR/wmt_enzh_32768k_tok_dev.lang2
#dev lang2 ?   why not lang1 ??

cat $OUTPUT_DIR/train.en | prepare_data/tokenizer.perl -l en | tr A-Z a-z > $OUTPUT_DIR/wmt_enzh_32768k_tok_train.lang2
cat $OUTPUT_DIR/newstest2017.en | prepare_data/tokenizer.perl -l en | tr A-Z a-z > $OUTPUT_DIR/wmt_enzh_32768k_tok_dev.lang1







# Tokenize data
# for f in ${OUTPUT_DIR}/*.zh; do
#   echo "Tokenizing $f..."
#   ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l zh -threads 8 < $f > ${f%.*}.tok.zh
# done

# for f in ${OUTPUT_DIR}/*.en; do
#   echo "Tokenizing $f..."
#   ${OUTPUT_DIR}/mosesdecoder/scripts/tokenizer/tokenizer.perl -q -l en -threads 8 < $f > ${f%.*}.tok.en
# done

# # Clean all corpora
# for f in ${OUTPUT_DIR}/*.zh; do
#   fbase=${f%.*}
#   echo "Cleaning ${fbase}..."
#   ${OUTPUT_DIR}/mosesdecoder/scripts/training/clean-corpus-n.perl $fbase en zh "${fbase}.clean" 1 80
# done

# # Create character vocabulary (on tokenized data)
# ${BASE_DIR}/bin/tools/generate_vocab.py --delimiter "" \
#   < ${OUTPUT_DIR}/train.tok.clean.en \
#   > ${OUTPUT_DIR}/vocab.tok.char.en
# ${BASE_DIR}/bin/tools/generate_vocab.py --delimiter "" \
#   < ${OUTPUT_DIR}/train.tok.clean.zh \
#   > ${OUTPUT_DIR}/vocab.tok.char.zh

# # Create character vocabulary (on non-tokenized data)
# ${BASE_DIR}/bin/tools/generate_vocab.py --delimiter "" \
#   < ${OUTPUT_DIR}/train.clean.en \
#   > ${OUTPUT_DIR}/vocab.char.en
# ${BASE_DIR}/bin/tools/generate_vocab.py --delimiter "" \
#   < ${OUTPUT_DIR}/train.clean.zh \
#   > ${OUTPUT_DIR}/vocab.char.zh

# # Create vocabulary for EN data
# $BASE_DIR/bin/tools/generate_vocab.py \
#    --max_vocab_size 50000 \
#   < ${OUTPUT_DIR}/train.tok.clean.en \
#   > ${OUTPUT_DIR}/vocab.50k.en \

# # Create vocabulary for zh data
# $BASE_DIR/bin/tools/generate_vocab.py \
#   --max_vocab_size 50000 \
#   < ${OUTPUT_DIR}/train.tok.clean.zh \
#   > ${OUTPUT_DIR}/vocab.50k.zh \

# echo "Please Select:
# 1.run process_data2.py
# 2.run process_data3.py"
# read -p "Enter selection [1 or 2] >" num
# if [[ $num =~ ^[0-2]$ ]]; then

#   if [[ $num == 1 ]]; then
#     python transformer/process_data2.py
#   fi
#   if [[ $num == 2 ]]; then
#     python transformer/process_data3.py
#   fi
#   if [[ $num == 0 ]]; then
#     echo "do nothing, exit."
#     exit;
#   fi

# else
#  echo "Invalid entry." >&2
#  exit 1
# fi





# python transformer/process_data2.py
# python transformer/process_data3.py

# # Generate Subword Units (BPE)
# # Clone Subword NMT
# if [ ! -d "${OUTPUT_DIR}/subword-nmt" ]; then
#   git clone https://github.com/rsennrich/subword-nmt.git "${OUTPUT_DIR}/subword-nmt"
# fi

# # Learn Shared BPE
# for merge_ops in 32000; do
#   echo "Learning BPE with merge_ops=${merge_ops}. This may take a while..."
#   cat "${OUTPUT_DIR}/train.tok.clean.zh" "${OUTPUT_DIR}/train.tok.clean.en" | \
#     ${OUTPUT_DIR}/subword-nmt/learn_bpe.py -s $merge_ops > "${OUTPUT_DIR}/bpe.${merge_ops}"

#   echo "Apply BPE with merge_ops=${merge_ops} to tokenized files..."
#   for lang in en zh; do
#     for f in ${OUTPUT_DIR}/*.tok.${lang} ${OUTPUT_DIR}/*.tok.clean.${lang}; do
#       outfile="${f%.*}.bpe.${merge_ops}.${lang}"
#       ${OUTPUT_DIR}/subword-nmt/apply_bpe.py -c "${OUTPUT_DIR}/bpe.${merge_ops}" < $f > "${outfile}"
#       echo ${outfile}
#     done
#   done

  # Create vocabulary file for BPE
  # cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.zh" | \
  #   ${OUTPUT_DIR}/subword-nmt/get_vocab.py | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.bpe.${merge_ops}"

  # cat "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.en" "${OUTPUT_DIR}/train.tok.clean.bpe.${merge_ops}.zh" \
  #    | cut -f1 -d ' ' > "${OUTPUT_DIR}/vocab.${merge_ops}"

# done

echo "All done."
