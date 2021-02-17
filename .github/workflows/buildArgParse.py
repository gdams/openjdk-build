import argparse
import json
import sys

def map_platforms(platforms):
    """ Takes in a list of platforms and translates Grinder platorms to corresponding GitHub-hosted runners.
        This function both modifies and returns the 'platforms' argument.
    """

    platform_map = {
        'windows': 'windows-latest',
        'macos': 'mac-latest',
        'linux': 'ubuntu-latest'
    }

    for i, platform in enumerate(platforms):
        if platform in platform_map:
            platforms[i] = platform_map[platform]

    return platforms

def underscore_targets(targets):
    """ Takes in a list of targets and prefixes them with an underscore if they do not have one.
    """
    result = []
    for target in targets:
        t = target
        if target[0] != '_':
            t = '_' + t
        result.append(t)
    return result

def main():

    # The keyword for this command.
    keyword = 'build'
    keywords = keyword.split()

    # We assume that the first argument is/are the keyword(s).
    # e.g. sys.argv == ['action_argparse.py', 'build', ...]
    raw_args = sys.argv[1 + len(keywords):]

    parser = argparse.ArgumentParser(prog=keyword, add_help=False)

    # Improvement: Automatically resolve the valid choices for each argument populate them below, rather than hard-coding choices.
    parser.add_argument('--platform', default=['linux'], nargs='+')
    parser.add_argument('--jdk_version', default=['jdk8u, jdk11u, jdk16, jdk'], nargs='+')
    parser.add_argument('--jdk_impl', default=['hotspot, openj9'], nargs='+')
    args = parser.parse_args(raw_args)

    output = {
      'platform': map_platforms(args.platform),
      'jdk_version': args.jdk_version,
      'jdk_impl': args.jdk_impl
    }
    # Set parameters as output: As JSON, and each item individually
    print('::set-output name=build_parameters::{}'.format(json.dumps(output)))
    for key, value in output.items():
      print('::set-output name={}::{}'.format(key, value))

if __name__ == "__main__":
    main()
