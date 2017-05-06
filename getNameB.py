import sys
import re

name_a = str(sys.argv[1])

num_identifier = re.search(r'[0-9]+', name_a).group(0)
alpha_identifier_a = re.search(r'(?<=[0-9])[A-Z]+', name_a).group(0)

if len(alpha_identifier_a) == 1:
    alpha_identifier_b = chr(ord(alpha_identifier_a) + 1)
else:
    alpha_identifier_b = alpha_identifier_a[0] + chr(ord(alpha_identifier_a[1]) + 1)

name_b = "DVB" + num_identifier + alpha_identifier_b

sys.stdout.write(name_b)
