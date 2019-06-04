#!/usr/bin/env bash

dataset=$1

for subject_dir in $dataset/*; do
    subject="$(basename $subject_dir)"
    cp "${subject}_config/imagelist.txt" $subject_dir
done
