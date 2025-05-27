#!/bin/zsh
piper-tts -m "$HOME/.local/voice/mv2.onnx" -f - -s 11 | aplay
