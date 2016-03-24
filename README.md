# categories

- NSString+MixedCodePage.h

NSString encoding methods sometimes return nil value, because text data has mixed with multiple codepages. 
this category using iconv or sequentially encode each bytes with separates codepages.
