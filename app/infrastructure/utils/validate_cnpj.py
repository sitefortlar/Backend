import re


def normalize_cnpj(cnpj: str) -> str:
    """Remove caracteres não-numéricos e retorna o CNPJ apenas com dígitos."""
    return re.sub(r"\D+", "", cnpj or "")


def is_valid_cnpj(cnpj: str) -> bool:
    """Valida CNPJ (14 dígitos) pelo algoritmo dos dígitos verificadores."""
    cnpj_digits = normalize_cnpj(cnpj)

    if len(cnpj_digits) != 14:
        return False

    # Rejeita sequências do mesmo dígito (ex: 00000000000000)
    if cnpj_digits == cnpj_digits[0] * 14:
        return False

    nums = [int(d) for d in cnpj_digits]

    def calc_dv(base: list[int], weights: list[int]) -> int:
        s = sum(n * w for n, w in zip(base, weights))
        r = s % 11
        return 0 if r < 2 else 11 - r

    w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]

    dv1 = calc_dv(nums[:12], w1)
    dv2 = calc_dv(nums[:12] + [dv1], w2)

    return nums[12] == dv1 and nums[13] == dv2

