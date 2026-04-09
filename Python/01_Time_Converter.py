def convert_minutes(minutes):
    hours = minutes // 60
    mins = minutes % 60

    if hours > 0 and mins > 0:
        return f"{hours} hrs {mins} minutes"
    elif hours > 0:
        return f"{hours} hr"
    else:
        return f"{mins} minutes"


print(convert_minutes(130))
print(convert_minutes(110))