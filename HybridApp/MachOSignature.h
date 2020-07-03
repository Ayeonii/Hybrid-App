//
//  MachOSignature.h
//  MachOSignDemo
//
//  Created by 罗贤明 on 2017/9/1.
//  Copyright © 2017年 罗贤明. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  macho 파일에서 서명 인증서 정보 갖고 오기
 */
@interface MachOSignature : NSObject


/**
  서명 인증서 정보 얻기

 @return  NSdictionary
        key Entitlements 서명 세부사항 ， 문자열 유형
        key EntitlementsHash 서명 값 (sha1) hash值,40비트 소문자 16진수。
        이러한 두 값이 없으면 안전하지 않은 것으로 간주 될 수있는 null을 반환합니다. (시뮬레이터 디버깅 상태에는 두 개의 값이 없지만 정상적인 상황에서는이 두 값이 있어야합니다.)
 */
- (NSDictionary *)loadCodeSignature; // 내부 인스턴스
+ (NSDictionary *)loadSignature; // 외부 클래스

@end
