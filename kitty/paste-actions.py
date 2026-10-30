def filter_paste(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")
