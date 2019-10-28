from django.contrib.messages.storage.base import BaseStorage
from django.contrib.messages.storage.cookie import CookieStorage
from django.contrib.messages.storage.session import SessionStorage


class FallbackStorage(BaseStorage):
    """
    尝试将所有消息存储在第一个后端中。将所有未存储的消息存储在每个后续后端中。
    """
    storage_classes = (CookieStorage, SessionStorage)

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.storages = [storage_class(*args, **kwargs)
                         for storage_class in self.storage_classes]
        self._used_storages = set()

    def _get(self, *args, **kwargs):
        """
        从所有存储后端获取单个消息列表。
        """
        all_messages = []
        for storage in self.storages:
            messages, all_retrieved = storage._get()
            # 如果尚未使用后​​端，则无需进行其他检索。
            if messages is None:
                break
            if messages:
                self._used_storages.add(storage)
            all_messages.extend(messages)
            # 如果此存储类包含所有消息，则无需进一步的检索
            if all_retrieved:
                break
        return all_messages, all_retrieved

    def _store(self, messages, response, *args, **kwargs):
        """
        尝试所有后端后，存储消息并返回所有未存储的消息。

        对于每个存储后端，所有未存储的消息都将传递到下一个后端。
        """
        for storage in self.storages:
            if messages:
                messages = storage._store(messages, response, remove_oldest=False)
            # 即使没有更多消息，也要继续进行迭代以确保刷新包含消息的个存储。
            elif storage in self._used_storages:
                storage._store([], response)
                self._used_storages.remove(storage)
        return messages
