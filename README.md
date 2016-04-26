# JKExtension
### JKExtension 是个人根据运行时,编写的一个简单框架,可以实现字典转模型和归档,使用起来非常简单,简洁
#### 一.字典转模型
##### 本代码可以实现模型数组属性中存放模型,只需简单在模型类中实现此方法,说明模型数组属性中存放的是什么类型的数据即可
```
- (NSDictionary *)objectClassInProArray;
```
##### 然后调用以下需要的任一方法即可
```
- (void)setDict:(NSDictionary *)dict;
+ (instancetype)objectWithDict:(NSDictionary *)dict;
```
#### 二.归档
##### 本代码可以实现解归档,只需在所要归档的类的实现中写入JKCodingImplement这句代码
##### 注意: 如果有不需要归档的属性,请实现此方法,返回需要忽略的参数名 
* eg. return @[@"name",@"age"] 或者 return @[@"_name",@"_age"] 两个效果一样
