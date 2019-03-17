#!/bin/bash -x

################################################################################
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

unset TEST

read -r -d '' java8 << EOM
openjdk version "1.8.0_202"
OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_202-b08)
OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.202-b08, mixed mode)
EOM

export TEST=$java8
RESULT=$(python version-parser.py fake/path/java 1)
IFS=', ' read -r -a result <<< "$RESULT"
if [ "${result[0]}" != 8 ]; then exit 1; fi
if [ "${result[1]}" != 0 ]; then exit 1; fi
if [ "${result[2]}" != 202 ]; then exit 1; fi
if [ "${result[3]}" != 08 ]; then exit 1; fi
if [ "${result[4]}" != "None" ]; then exit 1; fi
if [ "${result[5]}" != "8.0.202+08.1" ]; then exit 1; fi

read -r -d '' java8Nightly << EOM
openjdk version "1.8.0_181-internal"
OpenJDK Runtime Environment (AdoptOpenJDK)(build 1.8.0_181-internal-201903130451-b13)
OpenJDK 64-Bit Server VM (AdoptOpenJDK)(build 25.181-b13, mixed mode)
EOM

export TEST=$java8Nightly
RESULT=$(python version-parser.py fake/path/java 12)
IFS=', ' read -r -a result <<< "$RESULT"
if [ "${result[0]}" != 8 ]; then exit 1; fi
if [ "${result[1]}" != 0 ]; then exit 1; fi
if [ "${result[2]}" != 181 ]; then exit 1; fi
if [ "${result[3]}" != 13 ]; then exit 1; fi
if [ "${result[4]}" != 201903130451 ]; then exit 1; fi
if [ "${result[5]}" != "8.0.181+13.12" ]; then exit 1; fi

read -r -d '' java11 << EOM
openjdk version "11.0.2" 2018-10-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.2+7)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.2+7, mixed mode)
EOM

export TEST=$java11
RESULT=$(python version-parser.py fake/path/java 3)
IFS=', ' read -r -a result <<< "$RESULT"
if [ "${result[0]}" != 11 ]; then exit 1; fi
if [ "${result[1]}" != 0 ]; then exit 1; fi
if [ "${result[2]}" != 2 ]; then exit 1; fi
if [ "${result[3]}" != 7 ]; then exit 1; fi
if [ "${result[4]}" != "None" ]; then exit 1; fi
if [ "${result[5]}" != "11.0.2+7.3" ]; then exit 1; fi

read -r -d '' java11Nightly << EOM
openjdk version "11.0.3" 2019-04-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.3+9-201903122221)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.3+9-201903122221, mixed mode)
EOM

export TEST=$java11Nightly
RESULT=$(python version-parser.py fake/path/java 7)
IFS=', ' read -r -a result <<< "$RESULT"
if [ "${result[0]}" != 11 ]; then exit 1; fi
if [ "${result[1]}" != 0 ]; then exit 1; fi
if [ "${result[2]}" != 3 ]; then exit 1; fi
if [ "${result[3]}" != 9 ]; then exit 1; fi
if [ "${result[4]}" != 201903122221 ]; then exit 1; fi
if [ "${result[5]}" != "11.0.3+9.7" ]; then exit 1; fi

read -r -d '' java12Nightly << EOM
openjdk version "12" 2019-03-19
OpenJDK Runtime Environment AdoptOpenJDK (build 12+33-201903171631)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 12+33-201903171631, mixed mode, sharing)
EOM

export TEST=$java12Nightly
RESULT=$(python version-parser.py fake/path/java 11)
IFS=', ' read -r -a result <<< "$RESULT"
if [ "${result[0]}" != 12 ]; then exit 1; fi
if [ "${result[1]}" != 0 ]; then exit 1; fi
if [ "${result[2]}" != 0 ]; then exit 1; fi
if [ "${result[3]}" != 33 ]; then exit 1; fi
if [ "${result[4]}" != 201903171631 ]; then exit 1; fi
if [ "${result[5]}" != "12.0.0+33.11" ]; then exit 1; fi

unset TEST
