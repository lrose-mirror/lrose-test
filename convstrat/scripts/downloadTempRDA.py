import rdams_client as rc
import time

dsid = 'ds633.0'

metadata_response = rc.query(['-get_metadata', dsid])
# List of dicts representing a variable
_vars = metadata_response['result']['data']

# Just get temperature variables
TMP_variables = list(filter(lambda v: v['param'] == 'T',_vars)) 

# Let's say we're only interested in 2010
TMP_2010_variables = list(filter(
        lambda v: v['start_date'] < 201001010000 and v['end_date'] > 201101010000 ,TMP_variables
        )) 

# We only should have 1 variable
assert len(TMP_2010_variables) == 1
my_var = TMP_2010_variables[0]

# Now let's look at the levels available:
for lev in my_var['levels']:
    print('{:6} {:10} {}'.format(lev['level'], lev['level_value'],lev['level_description']))

# But let's say I only want Isobaric surfaces between 100 and 500Hpa. 
ISBL_levels = set()
for lev in my_var['levels']:
    if lev['level_description'] == 'Isobaric surface' \
            and float(lev['level_value']) >= 100 \
            and float(lev['level_value']) <= 500:
        ISBL_levels.add(lev['level_value'])
