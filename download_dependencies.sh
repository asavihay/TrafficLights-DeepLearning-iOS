#!/bin/sh

## Download Caffe Model
curl -L https://www.dropbox.com/s/05u4e10s0dysg7c/model.caffemodel?dl=1 -o ./model/model.caffemodel

## Download OpenCV2 extract it and remove the zipped source
curl -L0k https://www.dropbox.com/s/2nyxzmacqg71luz/opencv2.framework.zip?dl=1 -o opencv2.framework.zip
unzip opencv2.framework.zip -d TrafficLightApp/
rm opencv2.framework.zip
