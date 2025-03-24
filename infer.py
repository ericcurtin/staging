#!/usr/bin/env python3

import argparse
import subprocess
import sys
import os
import platform
import shutil
import json
import http.client
import readline

def detect_accelerator():
    if shutil.which('nvidia-smi') or os.path.exists('/dev/nvidia0'):
        return 'cuda'
    elif os.path.exists('/dev/kfd'):
        return 'rocm'
    elif platform.machine() == 'x86_64' and os.path.exists('/dev/dri'):
        return 'intel'
    return 'cpu'

def run_container(model, accelerator):
    image = f'ghcr.io/ggml-org/llama.cpp:full-{accelerator}'
    cmd = [
        'podman' if shutil.which('podman') else 'docker',
        'run', '-d', '-p', '8080:8080',
        '-v', f'{os.path.expanduser("~")}/.infer/models:/models',
        image, '-m', f'/models/{model}', '--host', '0.0.0.0'
    ]
    subprocess.run(cmd, check=True)

def interactive_client():
    conn = http.client.HTTPConnection('localhost', 8080)
    while True:
        try:
            prompt = input(">>> ")
            conn.request('POST', '/completion', json.dumps({
                'prompt': prompt,
                'stream': False
            }))
            response = conn.getresponse()
            print(json.loads(response.read())['content'])
        except KeyboardInterrupt:
            print("\nExiting...")
            break

def main():
    parser = argparse.ArgumentParser(
        prog='infer',
        description='Large language model runner',
        add_help=False
    )
    parser.add_argument('-h', '--help', action='store_true')
    parser.add_argument('-v', '--version', action='store_true')
    subparsers = parser.add_subparsers(dest='command')

    # Serve command
    serve_parser = subparsers.add_parser('serve', aliases=['start'], add_help=False)
    serve_parser.add_argument('-h', '--help', action='store_true')

    # Run command
    run_parser = subparsers.add_parser('run', add_help=False)
    run_parser.add_argument('model')
    run_parser.add_argument('prompt', nargs='?')
    run_parser.add_argument('--format')
    run_parser.add_argument('--insecure', action='store_true')
    run_parser.add_argument('--keepalive')
    run_parser.add_argument('--nowordwrap', action='store_true')
    run_parser.add_argument('--verbose', action='store_true')

    # Other commands omitted for brevity...
    
    args = parser.parse_args()

    if args.command == 'run':
        accelerator = detect_accelerator()
        run_container(args.model, accelerator)
        interactive_client()
    elif args.version:
        print("infer version 0.5.7")
    else:
        parser.print_help()

if __name__ == '__main__':
    main()

