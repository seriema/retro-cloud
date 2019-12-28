#!/bin/bash

sh ./install-ps.sh

pwsh -executionpolicy bypass -File ".\setup-az.ps1"
