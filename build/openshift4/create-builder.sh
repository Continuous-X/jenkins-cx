#!/bin/bash
oc process -f builder.yaml --param-file=builder.env | oc apply -f -