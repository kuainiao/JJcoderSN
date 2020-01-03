"""二分算法"""


def insort_right(a, x, lo=0, hi=None):
    """将元素x插入列表a，并假设a已排序，则使其保持排序。如果x已经在a中，则将其插入最右边x的右侧。
       可选的args lo（默认为0）和hi（默认为len（a））绑定了要搜索的a的切片。
    """

    lo = bisect_right(a, x, lo, hi)
    a.insert(lo, x)


def bisect_right(a, x, lo=0, hi=None):
    """假设对a排序，则返回将x插入列表a的索引。

    返回值i使得a [：i]中的所有e都具有e <= x，而a [i：]中的所有e都具有e> x。
    因此，如果x已经出现在列表中，则a.insert（x）将插入在最右边的x之后。

    可选的args lo（默认为0）和hi（默认为len（a））绑定了要搜索的a的切片。
    """

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo + hi) // 2
        # 使用__lt__匹配list.sort（）和heapq中的逻辑
        if x < a[mid]:
            hi = mid
        else:
            lo = mid + 1
    return lo  # 返回x在列表a中的索引


def insort_left(a, x, lo=0, hi=None):
    """将元素x插入列表a，并假设a已排序，则使其保持排序。如果x已经在a中，则将其插入最左侧x的左侧。

    可选的args lo（默认为0）和hi（默认为len（a））绑定了要搜索的a的切片。
    """

    lo = bisect_left(a, x, lo, hi)
    a.insert(lo, x)


def bisect_left(a, x, lo=0, hi=None):
    """假设对a排序，则返回将x插入列表a的索引。

    返回值i使得a [：i]中的所有e都等于e <x，而a [i：]中的所有e都等于e> = x。因此，如果x已经出现在列表中，则a.insert（x）将插入到最左边的x之前。

    可选的args lo（默认为0）和hi（默认为len（a））绑定了要搜索的a的切片。
    """

    if lo < 0:
        raise ValueError('lo must be non-negative')
    if hi is None:
        hi = len(a)
    while lo < hi:
        mid = (lo + hi) // 2
        # 使用__lt__匹配list.sort（）和heapq中的逻辑
        if a[mid] < x:
            lo = mid + 1
        else:
            hi = mid
    return lo


# 使用快速的C实现覆盖上述定义
try:
    from _bisect import *
except ImportError:
    pass

# 创建别名
bisect = bisect_right

# 排序很耗时，因此在得到一个有序的序列之后，我们最好能够保持他的有序，这就是insort存在的原因。
insort = insort_right

# 在默认情况下面，我们都是使用bisect（bisect_right）,但是对于bisect_right和bisect_left来说没有太大区别，只是对于列表中相同元素，
# 在插入元素x时，一个是放在原有元素的左边，一个是放在原有元素的右边。对于一些特殊的情况：1 == 1.0的返回值是True，但是他们是不同的两个
# 元素，所以在使用bisect_right和bisect_left来说需要特别注意。

"""
实例： 根据一个分数，找到它对应的成绩
def grade(score, breakpoints=[60, 70, 80, 90], grades='FDCBA')
    i = bisect.bisect(breakpoints, score)
    return grades[i]
[grade(score) for score in [33, 99, 77, 70, 89, 90, 100]]
"""
