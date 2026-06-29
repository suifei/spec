"""Tiny text utilities (Spec-Builder example project)."""
import re


def slugify(text: str, sep: str = "-") -> str:
    """Convert text into a URL-safe slug of lowercase ASCII words joined by `sep`."""
    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", sep, text)
    return text.strip(sep)
