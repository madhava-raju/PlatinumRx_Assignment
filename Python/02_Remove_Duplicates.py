def remove_duplicates(s):
    result = ""
    for char in s:
        if char not in result:
            result += char
    return result


print(remove_duplicates("hello"))
print(remove_duplicates("programming"))