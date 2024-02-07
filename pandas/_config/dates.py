"""
Configuration for datetime formatting in pandas.
"""

from __future__ import annotations
from pandas._config import config as cf
from pandas._config.config import BooleanValidator

pc_date_dayfirst_doc = """
: boolean
    When True, prints and parses dates with the day first, e.g., 20/01/2005
"""

pc_date_yearfirst_doc = """
: boolean
    When True, prints and parses dates with the year first, e.g., 2005/01/20
"""

with cf.config_prefix("display"):
    # Needed upstream of `_libs` because these are used in tslibs.parsing
    cf.reset_option("date_dayfirst")
    cf.reset_option("date_yearfirst")

    cf.register_option(
        "date_dayfirst",
        default=False,
        doc=pc_date_dayfirst_doc,
        validator=BooleanValidator(),
    )

    cf.register_option(
        "date_yearfirst",
        default=False,
        doc=pc_date_yearfirst_doc,
        validator=BooleanValidator(),
    )
