# TrafficLights-DeepLearning-iOS
Build A Deep Learning Real-Time Mobile Application With Caffe
The road towards a driving assistance app starts with a very simple first step

Code for the following [blog post](https://medium.com/@avihay/build-a-deep-learning-real-time-mobile-application-with-caffe-184d9062d7fc)

![TrafficLights](https://raw.githubusercontent.com/asavihay/TrafficLights-DeepLearning-iOS/master/screenshots/screenshot.png)

## Get started  

Clone the project (recursivly) to get Caffe as well:

```
$ git clone --recursive https://github.com/asavihay/TrafficLights-DeepLearning-iOS.git
```
Fetch OpenCV2 and our model file by running the script:
```
./download_dependencies.sh
```

## DIGITS Models
Using your own model is simple. Simply replace the files under the model directory with the ones your downloaded from DIGITS

## Thanks
Thanks to Aleph7 and noradaiko for the preliminary work that powered this example.
