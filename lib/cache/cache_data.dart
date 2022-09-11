class CacheData<K> {
  DateTime expireAt;
  K? data;

  CacheData(this.expireAt, {this.data});
}
