#!/usr/bin/env bash

generate_password() {
    openssl rand -hex 16
}

echo "Just copy the variables below and paste them into your ansible role variables file."
echo ""

echo "jitsi_jicofo_auth_password: $(generate_password)"
echo "jitsi_jvb_auth_password: $(generate_password)"
echo "jitsi_jigasi_xmpp_password: $(generate_password)"
echo "jitsi_jigasi_transcriber_password: $(generate_password)"
echo "jitsi_jibri_recorder_password: $(generate_password)"
echo "jitsi_jibri_xmpp_password: $(generate_password)"
