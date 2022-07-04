import copy

class Base:
  __slots__ = []

  def __init__(self, dict: dict):
    for v in self.__slots__:
      if v in dict:
          setattr(self, v, dict[v])
      else:
          setattr(self, v, None)

  def to_dict(self) -> dict:
    __dict = {}
    if len(self.__slots__) > 0:
      for key in self.__slots__:
        __dict[key] = self.__to_dict(getattr(self,key))
      return copy.deepcopy(__dict)
    else:
        return self.__dict__

  def __to_dict(self, item) -> dict:
    if isinstance(item, Base):
      return item.to_dict()
    else:
      if type(item) == dict:
        __dict = {}
        for k, v in item.items():
            __dict[k] = self.__to_dict(v)
        return __dict
      elif type(item) == list:
        __list = []
        for i in item:
            __list.append(self.__to_dict(i))
        return __list
      else:
        return item