#!/bin/bash

# deploy openshift gitops operator
oc apply -f . 

# monitor the deployment
while ! oc wait crd applications.argoproj.io --timeout=-1s --for=condition=Established  2>/dev/null;  do sleep 30; done
sleep 30
while ! oc wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n openshift-gitops > /dev/null; do sleep 30; done

echo "gitops deployed on cluster"