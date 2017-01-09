# TrafficLights-DeepLearning-iOS
Bringing Magic To Your Mobile App With Deep Learning - Teaching Your App To Detect Traffic Lights From 18,000 Images Is The First Step In Building Your Own Self Driving Car

Code for the following [blog post](https://medium.com/@avihay/bring-magic-to-your-mobile-app-with-deep-learning-184d9062d7fc)

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

Open the XCode project and run it

## DIGITS Models
Using your own model is simple. Simply replace the files under the model directory with the ones your downloaded from DIGITS

## Some Tips Before Trying It Yourself
* Caffe can be installed on various operating systems with or without a virtual environment. I do however recommend you to install it on a Ubuntu 14.04 machine without any virtualization (e.g. Docker/VirtualBox). It is quite complex to make it happen and you will be wasting time solving compilation problems instead of having fun.

* Under normal project setup, the optimization flag for your DEBUG build setting is set to None. This will cause the prediction code to run significantly slower than your production build. If you are testing your applications performance, make sure you change the optimization flag to Fastest [-Os]. On my iPhone 7 device I experienced a X3 performance increase.

## Thanks
Thanks to Aleph7 and noradaiko for the preliminary work that powered this example.
