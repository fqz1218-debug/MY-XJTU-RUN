;数据存储格式
;X_SIGN            DB 0          ;0为正，1为负
;X_INT             DD 100000     ;DQ为双字，32位，无符号数范围：0 ~ 2^32-1=4,294,967,295
;X_FRACTIONAL      DB '50000000' ;采用字符串形式，保留八位小数
;[SI]   -> X_SIGN
;[SI+1] -> X_INT
;[SI+5] -> x_FRA
.386
.MODEL HUGE
DATA SEGMENT
    CONST_1E8    EQU 100000000
    ;数据存储
	;X=+100 000.6
	X_SIGN            DB 0      ;+
	X_INT             DD 100000 ;100 000 
	X_FRACTIONAL      DB '60000000' ;.6
    MSG_X             DB 'X=$'
    MSG_INPUT_X       DB 'Please input X:$'
	;Y=-200 000.5
	Y_SIGN            DB 1      ;+
	Y_INT             DD 200000 ;200 000 
	Y_FRACTIONAL      DB '50000000' ;.5
    MSG_Y             DB 'Y=$'
    MSG_INPUT_Y       DB 'Please input Y:$'
    ;运算符
    OPERATOR          DB '+'
    MSG_INPUT_OP      DB 'Please input OPERATOR(+-*/):$'
	;Z
	Z_SIGN            DB 0      
	Z_INT             DD 0
	Z_FRACTIONAL      DB '00000000'   
    MSG_Z             DB 'Z=$'  
	;TEMP
	TEMP_SIGN         DB 0      
	TEMP_INT          DD 0      
	TEMP_FRACTIONAL   DB '00000000'  

    TEMP_X_LOW      DD 0
    TEMP_X_HIGH     DD 0
    TEMP_Y_LOW      DD 0
    TEMP_Y_HIGH     DD 0
    PRODUCT128_0    DD 0    ; 128位乘积 - 最低32位
    PRODUCT128_1    DD 0    ; 第32-63位
    PRODUCT128_2    DD 0    ; 第64-95位
    PRODUCT128_3    DD 0    ; 第96-127位

    QUOTIENT_0      DD 0    ; 商 - 低32位
    QUOTIENT_1      DD 0    ; 商 - 32-63
    QUOTIENT_2      DD 0    ; 商 - 63-95
    QUOTIENT_3      DD 0    ; 商 - 96-127
    REMAINDER_32    DD 0    ; 32位余数
    ;error
    MSG_ERROR         DB 0Dh,0Ah,'Input error! Please input again.',0Dh,0Ah,'$'
    MSG_OPERATOR_ERROR DB 0Dh,0Ah,'Operator error! ^-^',0Dh,0Ah,'$'
    MSG_CHU0_ERROR     DB 0Dh,0Ah,':(',0Dh,0Ah,0Dh,0Ah,'$'
    ;缓冲区
    BUFFER            DB 20 DUP(?)  ; 存储数字字符串
	;输入缓冲区
    INPUT_BUFFER     DB 20 DUP(?)  ; 输入缓冲区
    INPUT_LENGTH     DB 0          ; 输入长度
    ;表达式缓冲区

    

DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX
BEGIN:
    ;输入
    CALL INPUT_X  
    CALL INPUT_OPERATOR
    CALL INPUT_Y
    ; 显示输入值
    CALL DISPLAY_INPUTS

    ;Z=X OP Y
    CALL CALCULATE
    ; 显示结果
    CALL DISPLAY_RESULT

    JMP BEGIN
    ; 程序结束
DONE:    
    MOV AH, 4CH
    INT 21H


;输入运算符
INPUT_OPERATOR PROC NEAR
    PUSH AX
    PUSH DX
    
INPUT_OP_AGAIN:
    ; 显示提示信息
    MOV AH, 09H
    LEA DX, MSG_INPUT_OP
    INT 21H
    
    ; 读取一个字符
    MOV AH, 01H
    INT 21H
    
    ; 检查运算符是否合法
    CMP AL, '+'
    JE VALID_OPERATOR
    CMP AL, '-'
    JE VALID_OPERATOR
    CMP AL, '*'
    JE VALID_OPERATOR
    CMP AL, '/'
    JE VALID_OPERATOR
    
    ; 非法运算符
    MOV AH, 09H
    LEA DX, MSG_OPERATOR_ERROR
    INT 21H
    JMP INPUT_OP_AGAIN
    
VALID_OPERATOR:
    MOV OPERATOR, AL
    
    CALL PRINT_NEWLINE
    
    POP DX
    POP AX
    RET
INPUT_OPERATOR ENDP

;运算调用
CALCULATE PROC NEAR
    PUSH AX
    ;+
    CMP OPERATOR, '+'
    JE CALCULATE_DO_ADDITION
    ;-
    CMP OPERATOR, '-'
    JE CALCULATE_DO_SUBTRACTION
    ;*
    CMP OPERATOR, '*'
    JE CALCULATE_DO_MULTIPLICATION
    ;/
    CMP OPERATOR, '/'
    JE CALCULATE_DO_DIVISION

CALCULATE_DO_ADDITION:
    CALL PLUS
    JMP CALC_DONE
    
CALCULATE_DO_SUBTRACTION:
    ; 将Y的符号取反
    MOV AL, Y_SIGN
    XOR AL, 1          ; 0变1，1变0
    MOV Y_SIGN, AL
    CALL PLUS
    ; 恢复Y的原始符号
    MOV AL, Y_SIGN
    XOR AL, 1
    MOV Y_SIGN, AL
    JMP CALC_DONE

CALCULATE_DO_MULTIPLICATION:
    CALL MULTIPLY
    JMP CALC_DONE

CALCULATE_DO_DIVISION:
    CALL DIVIDE
    JMP CALC_DONE
    
CALC_DONE:
    POP AX
    RET
CALCULATE ENDP

;输入X
INPUT_X PROC NEAR
    PUSH AX
    PUSH DX
    PUSH SI
    
INPUT_X_AGAIN:
    ; 显示提示信息
    MOV AH, 09H
    LEA DX, MSG_INPUT_X
    INT 21H
    
    ; 读取输入
    CALL READ_INPUT
    
    ; 解析输入到X
    LEA SI, X_SIGN
    CALL PARSE_INPUT
    
    ; 检查是否解析成功
    JC INPUT_X_AGAIN  ; 如果出错，重新输入
    
    POP SI
    POP DX
    POP AX
    RET
INPUT_X ENDP

; 输入Y值
INPUT_Y PROC NEAR
    PUSH AX
    PUSH DX
    PUSH SI
    
INPUT_Y_AGAIN:
    ; 显示提示信息
    MOV AH, 09H
    LEA DX, MSG_INPUT_Y
    INT 21H
    
    ; 读取输入
    CALL READ_INPUT
    
    ; 解析输入到Y
    LEA SI, Y_SIGN
    CALL PARSE_INPUT
    
    ; 检查是否解析成功
    JC INPUT_Y_AGAIN  ; 如果出错，重新输入
    
    POP SI
    POP DX
    POP AX
    RET
INPUT_Y ENDP


; 读取输入字符串
READ_INPUT PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DI
    
    LEA DI, INPUT_BUFFER
    MOV CX, 19        ; 最大输入长度
    
READ_LOOP:
    MOV AH, 01H       ; 读取一个字符
    INT 21H
    
    CMP AL, 0Dh       ; 检查回车
    JE READ_DONE
    
    CMP AL, 08H       ; 检查退格
    JE BACKSPACE
    
    ; 检查字符是否合法
    CALL IS_VALID_CHAR
    JNC STORE_CHAR
    
    ; 非法字符，忽略
    JMP READ_LOOP
    
STORE_CHAR:
    MOV [DI], AL      ; 存储字符
    INC DI
    DEC CX
    JNZ READ_LOOP
    
READ_DONE:
    MOV BYTE PTR [DI], '$'  ; 字符串结束符
    ; 正确计算和存储长度
    MOV AX, DI
    SUB AX, OFFSET INPUT_BUFFER
    MOV INPUT_LENGTH, AL
    JMP READ_EXIT
    
BACKSPACE:
    CMP DI, OFFSET INPUT_BUFFER
    JBE READ_LOOP     ; 已经在开头，忽略
    DEC DI
    INC CX
    ; 显示退格效果
    MOV AH, 02H
    MOV DL, 20H       ; 空格
    INT 21H
    MOV DL, 08H       ; 退格
    INT 21H
    JMP READ_LOOP
    
READ_EXIT:
    CALL PRINT_NEWLINE
    POP DI
    POP CX
    POP AX
    RET
READ_INPUT ENDP


; 检查字符是否合法 (0-9, +, -, .)
IS_VALID_CHAR PROC NEAR
    CMP AL, '+'
    JE VALID_CHAR
    CMP AL, '-'
    JE VALID_CHAR
    CMP AL, '.'
    JE VALID_CHAR
    CMP AL, '0'
    JB INVALID_CHAR
    CMP AL, '9'
    JA INVALID_CHAR
    
VALID_CHAR:
    CLC
    RET
    
INVALID_CHAR:
    STC
    RET
IS_VALID_CHAR ENDP


; 解析输入字符串到数字结构
; 输入: SI指向数字结构
; 输出: CF=0成功, CF=1失败
PARSE_INPUT PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH DI
    PUSH SI
    
    ; 初始化结构
    MOV BYTE PTR [SI], 0          ; 符号为正
    MOV DWORD PTR [SI+1], 0       ; 整数部分清零
    
    ; 初始化小数部分为'00000000'
    MOV CX, 8
    MOV DI, SI
    ADD DI, 5
INIT_FRAC_LOOP:
    MOV BYTE PTR [DI], '0'
    INC DI
    LOOP INIT_FRAC_LOOP
    
    LEA DI, INPUT_BUFFER
    MOV CL, INPUT_LENGTH
    MOV CH, 0
    
    ; 检查空输入
    CMP CX, 0
    JNE NOT_EMPTY
    CALL SHOW_ERROR
    JMP PARSE_ERROR
    
NOT_EMPTY:
    ; 检查符号
    MOV AL, [DI]
    CMP AL, '+'
    JE HAS_SIGN
    CMP AL, '-'
    JNE CHECK_DIGIT_START
    
HAS_SIGN:
    ; 处理符号
    CMP AL, '-'
    JNE POSITIVE_SIGN
    MOV BYTE PTR [SI], 1          ; 设置为负号
    
POSITIVE_SIGN:
    INC DI
    DEC CX
    JNZ CHECK_DIGIT_START         ; 如果还有字符，继续
    CALL SHOW_ERROR               ; 否则错误
    JMP PARSE_ERROR
    
CHECK_DIGIT_START:
    ; 解析整数部分
    XOR EBX, EBX                  ; 用于存储整数
    
INT_LOOP:
    CMP CX, 0
    JE PARSE_INPUT_STORE_RESULT
    
    MOV AL, [DI]
    CMP AL, '.'
    JE FRAC_PART
    
    ; 检查数字
    CMP AL, '0'
    JB PARSE_ERROR
    CMP AL, '9'
    JA PARSE_ERROR
    
    ; 更新整数值: EBX = EBX * 10 + (AL - '0')
    MOV EAX, EBX
    MOV EDX, 10
    MUL EDX                       ; EAX = EAX * 10
    JC PARSE_ERROR                ; 溢出错误
    
    MOV EBX, EAX
    MOV AL, [DI]
    SUB AL, '0'
    MOVZX EAX, AL
    ADD EBX, EAX                  ; EBX = EBX + 新数字
    JC PARSE_ERROR                ; 溢出错误
    
    INC DI
    DEC CX
    JMP INT_LOOP
    
FRAC_PART:
    INC DI                        ; 跳过小数点
    DEC CX
    JZ PARSE_INPUT_STORE_RESULT               ; 如果小数点后没有字符，也OK
    
    ; 解析小数部分 - 简化版本
    ; 使用栈保存寄存器
    PUSH DI                      ; 保存输入缓冲区位置
    PUSH CX                      ; 保存剩余字符计数
    
    ; 设置小数部分指针
    MOV DI, SI
    ADD DI, 5                    ; DI指向小数部分存储位置
    XOR DX, DX                   ; DX = 小数位数计数
    
FRAC_LOOP:
    CMP DX, 8
    JAE FRAC_DONE                ; 最多8位小数
    
    ; 检查是否还有字符
    POP CX                       ; 恢复剩余字符计数
    POP DI                       ; 恢复输入缓冲区位置
    CMP CX, 0
    JE FRAC_DONE_NO_PUSH
    
    ; 读取字符
    MOV AL, [DI]
    
    ; 检查是否为数字
    CMP AL, '0'
    JB FRAC_DONE_NO_PUSH
    CMP AL, '9'
    JA FRAC_DONE_NO_PUSH
    
    ; 存储小数位
    PUSH DI                      ; 保存输入缓冲区位置
    PUSH CX                      ; 保存剩余字符计数
    MOV DI, SI
    ADD DI, 5
    ADD DI, DX                   ; 移动到正确的小数位置
    MOV [DI], AL                 ; 存储小数位
    
    ; 更新计数器和指针
    INC DX                       ; 增加小数位数
    POP CX                       ; 恢复剩余字符计数
    POP DI                       ; 恢复输入缓冲区位置
    INC DI                       ; 移动到下一个输入字符
    DEC CX                       ; 减少剩余字符计数
    
    ; 保存状态并继续循环
    PUSH DI
    PUSH CX
    JMP FRAC_LOOP
    
FRAC_DONE:
    POP CX                       ; 清理栈
    POP DI
    
FRAC_DONE_NO_PUSH:
    ; 不需要清理栈，直接继续
    
PARSE_INPUT_STORE_RESULT:
    ; 存储整数部分
    MOV DWORD PTR [SI+1], EBX     ; 存储整数部分
    CLC
    JMP PARSE_EXIT

PARSE_ERROR:
    CALL SHOW_ERROR
    STC
    
PARSE_EXIT:
    POP SI
    POP DI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET

; 局部错误显示子程序
SHOW_ERROR PROC NEAR
    PUSH AX
    PUSH DX
    MOV AH, 09H
    LEA DX, MSG_ERROR
    INT 21H
    POP DX
    POP AX
    RET
SHOW_ERROR ENDP

PARSE_INPUT ENDP


; 显示输入值子程序
DISPLAY_INPUTS PROC NEAR
    PUSH AX
    PUSH DX
    PUSH SI

    ; 显示X
    MOV AH, 09H
    LEA DX, MSG_X
    INT 21H
    LEA SI, X_SIGN
    CALL DISPLAY_NUMBER
    CALL PRINT_NEWLINE

    ; 显示Y
    MOV AH, 09H
    LEA DX, MSG_Y
    INT 21H
    LEA SI, Y_SIGN
    CALL DISPLAY_NUMBER
    CALL PRINT_NEWLINE

    POP SI
    POP DX
    POP AX
    RET
DISPLAY_INPUTS ENDP

; 显示结果子程序
DISPLAY_RESULT PROC NEAR
    PUSH AX
    PUSH DX
    PUSH SI

    ; 显示Z
    MOV AH, 09H
    LEA DX, MSG_Z
    INT 21H
    LEA SI, Z_SIGN
    CALL DISPLAY_NUMBER
    CALL PRINT_NEWLINE

    POP SI
    POP DX
    POP AX
    RET
DISPLAY_RESULT ENDP

; 显示数字子程序（优化输出格式）
; 输入：SI指向数字结构（SIGN, INT, FRACTIONAL）
DISPLAY_NUMBER PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH SI
    PUSH DI
    
    ; 显示符号
    MOV AL, [SI]
    CMP AL, 0
    JE POSITIVE
    MOV AH, 02H
    MOV DL, '-'
    INT 21H
    JMP DISPLAY_INT

POSITIVE:

DISPLAY_INT:
    ; 显示整数部分
    ADD SI, 1  ; 指向INT部分
    MOV EAX, DWORD PTR [SI]      ; 将32位数存储在EAX中
    CALL DISPLAY_DWORD_DECIMAL

    ; 检查小数部分是否全为0
    ADD SI, 4                    ; 指向FRACTIONAL部分
    MOV CX, 8
    MOV DI, SI
CHECK_ZERO_FRAC:
    CMP BYTE PTR [DI], '0'
    JNE HAS_FRACTION
    INC DI
    LOOP CHECK_ZERO_FRAC
    
    ; 小数部分全为0，不显示小数点和后面的0
    JMP DISPLAY_END

HAS_FRACTION:
    ; 显示小数点
    MOV AH, 02H
    MOV DL, '.'
    INT 21H
    
    ; 显示小数部分，去除末尾的0
    MOV CX, 8
    MOV DI, SI
    ADD DI, 7                    ; 指向最后一位
    
    ; 找到最后一个非0的位置
FIND_LAST_NONZERO:
    CMP BYTE PTR [DI], '0'
    JNE FOUND_LAST
    DEC DI
    LOOP FIND_LAST_NONZERO
    
FOUND_LAST:
    ; 计算要显示的小数位数
    MOV CX, DI
    SUB CX, SI
    INC CX                      ; CX = 要显示的小数位数
    
    ; 显示小数部分
    MOV DI, SI
DISPLAY_FRAC:
    MOV AH, 02H
    MOV DL, [DI]
    INT 21H
    INC DI
    LOOP DISPLAY_FRAC

DISPLAY_END:
    POP DI
    POP SI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
DISPLAY_NUMBER ENDP

;无符号32位二进制数的十进制显示
;数据存放于EAX
DISPLAY_DWORD_DECIMAL PROC NEAR
    PUSH EAX
    PUSH EDX
    PUSH ECX
    PUSH DI

    LEA DI, BUFFER+19 
    MOV BYTE PTR [DI], '$'      
    DEC DI            ;指向个位

    ; 如果EAX为0，直接显示0
    CMP EAX, 0
    JNE DIV_LOOP
    MOV BYTE PTR [DI], '0'
    DEC DI
    JMP DISPLAY_INT_PART

DIV_LOOP:
    MOV ECX, 10
    XOR EDX, EDX
    DIV ECX
    ADD DL, '0'        ;转化为ASCII
    MOV [DI], DL       ;存储余数，即为整数部分的对应位数的值
    DEC DI

    OR EAX, EAX        ;商不为0循环
    JNZ DIV_LOOP

DISPLAY_INT_PART:
    ; 显示整数部分
    MOV AH, 09H
    MOV DX, DI
    INC DX             ;指向第一个数字
    INT 21H

    POP DI
    POP ECX
    POP EDX
    POP EAX
    RET 
DISPLAY_DWORD_DECIMAL ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;加法实现
PLUS PROC NEAR
    PUSH SI
    PUSH DI
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX

    ; 复制X到TEMP
    LEA SI, X_SIGN
    LEA DI, TEMP_SIGN
    CALL COPY_NUMBER
    
    ; 将Y加到TEMP
    LEA SI, Y_SIGN
    LEA DI, TEMP_SIGN  
    CALL ADD_NUMBERS
    
    ; 复制结果到Z
    LEA SI, TEMP_SIGN
    LEA DI, Z_SIGN
    CALL COPY_NUMBER

    POP EDX
    POP ECX
    POP EBX
    POP EAX
    POP DI
    POP SI 
    RET 
PLUS ENDP

; 复制数字结构
; 输入: SI->源, DI->目标
COPY_NUMBER PROC NEAR
    PUSH AX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV AL, [SI]
    MOV [DI], AL              ; 复制符号
    
    MOV EAX, [SI+1]
    MOV [DI+1], EAX           ; 复制整数部分
    
    MOV CX, 8
    ADD SI, 5
    ADD DI, 5
COPY_FRAC:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPY_FRAC
    
    POP DI
    POP SI
    POP CX
    POP AX
    RET
COPY_NUMBER ENDP

; 数字相加
; 输入: SI->加数, DI->被加数(结果)
ADD_NUMBERS PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH SI
    PUSH DI
    
    ; 符号相同则直接相加
    MOV AL, [SI]
    MOV BL, [DI]
    CMP AL, BL
    JNE DIFF_SIGN_ADD
    
    ; 同号相加
    CALL ADD_ABS_VALUES
    JMP ADD_END
    
DIFF_SIGN_ADD:
    ; 异号相减
    CALL SUB_ABS_VALUES
    
ADD_END:
    POP DI
    POP SI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
ADD_NUMBERS ENDP

; 绝对值相加
ADD_ABS_VALUES PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH SI
    PUSH DI
    
    ; 小数部分相加
    MOV CX, 8
    MOV DH, 0                   ; 进位标志
    ADD SI, 5
    ADD DI, 5
    ADD SI, 7                   ; 指向小数部分最后一位
    ADD DI, 7
    
FRAC_ADD_LOOP:
    MOV AL, [SI]
    SUB AL, '0'
    MOV BL, [DI]
    SUB BL, '0'
    ADD AL, BL
    ADD AL, DH                  ; 加上进位
    MOV DH, 0                   ; 清除进位
    CMP AL, 10
    JB NO_CARRY_FRAC
    SUB AL, 10
    MOV DH, 1                   ; 设置进位
NO_CARRY_FRAC:
    ADD AL, '0'
    MOV [DI], AL
    DEC SI
    DEC DI
    LOOP FRAC_ADD_LOOP
    
    ; 整数部分相加
    SUB SI, 3                   ; 调整到整数部分
    SUB DI, 3
    MOV EAX, [SI]
    MOV EBX, [DI]
    ADD EAX, EBX
    MOVZX EDX,DH
    ADD EAX, EDX                ; 加上小数部分的进位
    MOV [DI], EAX
    
    POP DI
    POP SI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
ADD_ABS_VALUES ENDP

; 绝对值相减 (DI绝对值 >= SI绝对值) 
SUB_ABS_VALUES PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH SI
    PUSH DI
    
    ; 保存原始符号
    MOV AL, [DI]  ; 目标符号
    MOV BL, [SI]  ; 源符号
    
    ; 比较绝对值大小
    CALL COMPARE_ABS
    JC DI_GREATER
    
    ; SI绝对值 > DI绝对值
    ; 交换两个数，结果符号与源符号相同
    PUSH SI
    PUSH DI
    CALL SWAP_NUMBERS
    POP DI
    POP SI
    MOV [DI], BL  ; 设置结果为源符号
    
    JMP DO_SUBTRACTION
    
DI_GREATER:
    ; DI绝对值 >= SI绝对值
    ; 不交换，结果符号与目标符号相同
    MOV [DI], AL  ; 保持目标符号
    
DO_SUBTRACTION:
    ; 现在DI绝对值 >= SI绝对值
    
    ; 保存原始位置用于小数部分相减
    PUSH SI
    PUSH DI
    
    ; 小数部分相减
    MOV CX, 8
    MOV DH, 0                   ; 借位标志
    ADD SI, 5
    ADD DI, 5
    ADD SI, 7                   ; 指向小数部分最后一位
    ADD DI, 7                   ; 指向小数部分最后一位
    
FRAC_SUB_LOOP:
    MOV AL, [DI]
    SUB AL, '0'
    MOV AH, [SI]
    SUB AH, '0'
    SUB AL, AH
    SUB AL, DH                  ; 减去借位
    MOV DH, 0                   ; 清除借位
    JNC NO_BORROW_FRAC
    ADD AL, 10
    MOV DH, 1                   ; 设置借位
NO_BORROW_FRAC:
    ; 确保结果在0-9范围内
    CMP AL, 0
    JGE STORE_FRAC
    ADD AL, 10
    MOV DH, 1                   ; 需要借位
STORE_FRAC:
    ADD AL, '0'
    MOV [DI], AL
    DEC SI
    DEC DI
    LOOP FRAC_SUB_LOOP
    
    ; 恢复原始位置用于整数部分相减
    POP DI
    POP SI
    
    ; 整数部分相减
    MOV EAX, [DI+1]             ; 目标整数部分
    MOV EBX, [SI+1]             ; 源整数部分
    MOVZX EDX, DH               ; 将借位扩展到32位
    SUB EAX, EBX
    SUB EAX, EDX                ; 减去小数部分的借位
    MOV [DI+1], EAX             ; 存储结果
    
    ; 检查结果是否为0
    CMP EAX, 0
    JNZ CHECK_FRACTION_ZERO
    
    ; 整数部分为0，检查小数部分是否全为0
    MOV CX, 8
    MOV BX, DI
    ADD BX, 5                   ; 指向小数部分开始
CHECK_FRAC_ZERO_LOOP:
    CMP BYTE PTR [BX], '0'
    JNE CHECK_FRACTION_ZERO
    INC BX
    LOOP CHECK_FRAC_ZERO_LOOP
    
    ; 结果为0，设置符号为正
    MOV BYTE PTR [DI], 0
    
CHECK_FRACTION_ZERO:
    POP DI
    POP SI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
SUB_ABS_VALUES ENDP

; 比较绝对值 (DI和SI指向的数字结构)
; 输出: CF=1 if |DI| >= |SI|
COMPARE_ABS PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH CX
    PUSH SI
    PUSH DI
    
    ; 比较整数部分
    MOV EAX, [DI+1]
    MOV EBX, [SI+1]
    CMP EAX, EBX
    JA DI_GREATER_CMP
    JB SI_GREATER_CMP
    
    ; 整数部分相等，比较小数部分
    MOV CX, 8
    ADD DI, 5
    ADD SI, 5
    
COMPARE_FRAC:
    MOV AL, [DI]
    MOV BL, [SI]
    CMP AL, BL
    JA DI_GREATER_CMP
    JB SI_GREATER_CMP
    INC DI
    INC SI
    LOOP COMPARE_FRAC
    
    ; 完全相等
    STC
    JMP CMP_END
    
DI_GREATER_CMP:
    STC
    JMP CMP_END
    
SI_GREATER_CMP:
    CLC
    
CMP_END:
    POP DI
    POP SI
    POP CX
    POP EBX
    POP EAX
    RET
COMPARE_ABS ENDP




;;;;;;;;;;;;;;;;;
;乘法算法入口
MULTIPLY PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    ; 计算符号
    MOV AL, X_SIGN
    XOR AL, Y_SIGN
    MOV Z_SIGN, AL
    
    ; 使用正确的乘法算法
    CALL MULTIPLY_CORRECT
    
    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
MULTIPLY ENDP

; 乘法算法
MULTIPLY_CORRECT PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    ; 将X转换为64位整数：X_INT * 1e8 + X_FRAC_VALUE
    MOV EAX, X_INT
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = X_INT * 1e8
    PUSH EDX
    PUSH EAX
    
    LEA SI, X_FRACTIONAL
    CALL CONVERT_FRAC_TO_NUM   ; EAX = X_FRAC_VALUE
    
    POP EBX
    POP EDX
    ADD EBX, EAX
    ADC EDX, 0
    MOV DWORD PTR TEMP_X_LOW, EBX
    MOV DWORD PTR TEMP_X_HIGH, EDX
    
    ; 将Y转换为64位整数：Y_INT * 1e8 + Y_FRAC_VALUE
    MOV EAX, Y_INT
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = Y_INT * 1e8
    PUSH EDX
    PUSH EAX
    
    LEA SI, Y_FRACTIONAL
    CALL CONVERT_FRAC_TO_NUM   ; EAX = Y_FRAC_VALUE
    
    POP EBX
    POP EDX
    ADD EBX, EAX
    ADC EDX, 0
    MOV DWORD PTR TEMP_Y_LOW, EBX
    MOV DWORD PTR TEMP_Y_HIGH, EDX
    
    ; 执行64位乘法，得到128位结果
    CALL MULTIPLY_64_TO_128
    
    ; 现在有128位结果 = (X * 1e8) * (Y * 1e8) = X*Y * 1e16
    ; 需要除以1e8得到 X*Y * 1e8
    ; 使用128位除法
    CALL DIVIDE_128_BY_1E8_SAFE
    
    ; 现在64位商在 QUOTIENT64_LOW:QUOTIENT64_HIGH 中
    ; 需要再次除以1e8得到整数部分和余数（小数部分）
 MOV EAX, DWORD PTR QUOTIENT_0
    MOV EDX, DWORD PTR QUOTIENT_1
    MOV EBX, 100000000
    
    

    ; 检查是否为64位除法
    CMP EDX, 0
    JNE MUL_DO_64BIT_DIV
    
    ; 32位除法
    DIV EBX                    ; EAX = 商（整数部分）, EDX = 余数（小数部分）
    JMP MUL_STORE_RESULT
    
MUL_DO_64BIT_DIV:
    ; 64位除以32位
    PUSH EAX                  ; 保存低32位
    MOV EAX, EDX              ; 高32位到EAX
    XOR EDX, EDX              ; 清零EDX
    DIV EBX                   ; EAX = 高32位的商, EDX = 高32位的余数
    MOV ECX, EAX              ; 保存高32位的商
    POP EAX                   ; 恢复低32位
    DIV EBX                   ; EAX = 低32位的商, EDX = 余数
    ; 最终商在 ECX:EAX 中，但ECX应该为0（因为除以1e8后）
    ; 所以整数部分在EAX，余数在EDX
    
MUL_STORE_RESULT:
    MOV Z_INT, EAX            ; 直接存储整数部分，
    
    ; 将小数部分数值转换为字符串
    MOV EAX, EDX              ; 直接使用余数，
    LEA DI, Z_FRACTIONAL
    CALL CONVERT_NUM_TO_FRAC
    
    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
MULTIPLY_CORRECT ENDP

; 64位乘法，产生128位结果
MULTIPLY_64_TO_128 PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    
    ; 清零128位结果
    MOV DWORD PTR PRODUCT128_0, 0
    MOV DWORD PTR PRODUCT128_1, 0
    MOV DWORD PTR PRODUCT128_2, 0
    MOV DWORD PTR PRODUCT128_3, 0
    
    ; 低32位 × 低32位
    MOV EAX, DWORD PTR TEMP_X_LOW
    MOV EBX, DWORD PTR TEMP_Y_LOW
    MUL EBX
    MOV DWORD PTR PRODUCT128_0, EAX
    MOV DWORD PTR PRODUCT128_1, EDX
    
    ; 低32位 × 高32位
    MOV EAX, DWORD PTR TEMP_X_LOW
    MOV EBX, DWORD PTR TEMP_Y_HIGH
    MUL EBX
    ADD DWORD PTR PRODUCT128_1, EAX
    ADC DWORD PTR PRODUCT128_2, EDX
    ADC DWORD PTR PRODUCT128_3, 0
    
    ; 高32位 × 低32位
    MOV EAX, DWORD PTR TEMP_X_HIGH
    MOV EBX, DWORD PTR TEMP_Y_LOW
    MUL EBX
    ADD DWORD PTR PRODUCT128_1, EAX
    ADC DWORD PTR PRODUCT128_2, EDX
    ADC DWORD PTR PRODUCT128_3, 0
    
    ; 高32位 × 高32位
    MOV EAX, DWORD PTR TEMP_X_HIGH
    MOV EBX, DWORD PTR TEMP_Y_HIGH
    MUL EBX
    ADD DWORD PTR PRODUCT128_2, EAX
    ADC DWORD PTR PRODUCT128_3, EDX
    
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
MULTIPLY_64_TO_128 ENDP





;;;;;;;;;;;;;;;;;;;;
;除法实现
DIVIDE PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    ; 计算符号
    MOV AL, X_SIGN
    XOR AL, Y_SIGN
    MOV Z_SIGN, AL
    
    ; 检查除数是否为0
    CALL CHECK_DIVISOR_ZERO
    JC DIVIDE_BY_ZERO_ERROR
    
    ; 使用准确除法算法
    CALL ACCURATE_DIVIDE
    
    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET

DIVIDE_BY_ZERO_ERROR:
    MOV AH, 09H
    LEA DX, MSG_CHU0_ERROR
    INT 21H 

    MOV Z_SIGN, 0
    MOV DWORD PTR Z_INT, 0FFFFFFFFh
    LEA DI, Z_FRACTIONAL
    MOV CX, 8
    MOV AL, 'E'
DIV_ERROR_LOOP:
    MOV [DI], AL
    INC DI
    LOOP DIV_ERROR_LOOP
    JMP BEGIN
DIVIDE ENDP

ACCURATE_DIVIDE PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    ; 1. 将X转换为64位整数：X64 = X_INT * 1e8 + X_FRAC_VALUE
    MOV EAX, X_INT
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = X_INT * 1e8
    
    PUSH EDX
    PUSH EAX
    LEA SI, X_FRACTIONAL
    CALL CONVERT_FRAC_TO_NUM   ; EAX = X_FRAC_VALUE
    POP EBX
    POP EDX
    ADD EBX, EAX
    ADC EDX, 0
    MOV DWORD PTR TEMP_X_LOW, EBX
    MOV DWORD PTR TEMP_X_HIGH, EDX      ; TEMP_X_HIGH:TEMP_X_LOW = X64
    
    ; 2. 将Y转换为64位整数：Y64 = Y_INT * 1e8 + Y_FRAC_VALUE
    MOV EAX, Y_INT
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = Y_INT * 1e8
    
    PUSH EDX
    PUSH EAX
    LEA SI, Y_FRACTIONAL
    CALL CONVERT_FRAC_TO_NUM   ; EAX = Y_FRAC_VALUE
    POP EBX
    POP EDX
    ADD EBX, EAX
    ADC EDX, 0
    MOV DWORD PTR TEMP_Y_LOW, EBX
    MOV DWORD PTR TEMP_Y_HIGH, EDX      ; TEMP_Y_HIGH:TEMP_Y_LOW = Y64
    
    

    ; 3. 给X64乘1e8：X128 = X64 * 1e8
    ; 计算低32位 * 1e8
    MOV EAX, TEMP_X_LOW
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = TEMP_X_LOW * 1e8
    MOV PRODUCT128_0, EAX      ; 最低32位
    MOV PRODUCT128_1, EDX      ; 次低32位
    
    ; 计算高32位 * 1e8
    MOV EAX, TEMP_X_HIGH
    MOV EBX, 100000000
    MUL EBX                    ; EDX:EAX = TEMP_X_HIGH * 1e8
    ADD PRODUCT128_1, EAX
    ADC PRODUCT128_2, EDX
    ADC PRODUCT128_3, 0        ; 最高32位
    
    ; 4. 执行除法：Q128 = X128 / Y64
    CALL DIVIDE_128_BY_64_ACCURATE
    
    ; 5. 将128位商拆分为整数部分和小数部分
    ; Q128 = (X128 / Y64) = (X * 1e16) / (Y * 1e8) = (X/Y) * 1e8
    
    ; 检查商的高64位是否为0
    MOV EAX, DWORD PTR QUOTIENT_2
    OR EAX, DWORD PTR QUOTIENT_3
    JNZ HANDLE_LARGE_QUOTIENT
    
    ; 商在64位范围内，使用低64位
    MOV EAX, DWORD PTR QUOTIENT_0
    MOV EDX, DWORD PTR QUOTIENT_1
    MOV EBX, 100000000
    
    ; 检查商的高32位是否为0
    CMP EDX, 0
    JNE DO_64BIT_DIV_ACCURATE
    
    ; 32位除法
    DIV EBX                    ; EAX = 整数部分, EDX = 小数部分
    MOV Z_INT, EAX
    MOV EAX, EDX
    LEA DI, Z_FRACTIONAL
    CALL CONVERT_NUM_TO_FRAC
    JMP DIV_DONE_ACCURATE
    
DO_64BIT_DIV_ACCURATE:
    ; 64位除以32位
    PUSH EAX                  ; 保存低32位
    MOV EAX, EDX              ; 高32位到EAX
    XOR EDX, EDX              ; 清零EDX
    DIV EBX                   ; EAX = 高32位的商, EDX = 高32位的余数
    MOV ECX, EAX              ; 保存高32位的商
    POP EAX                   ; 恢复低32位
    DIV EBX                   ; EAX = 低32位的商, EDX = 余数
    ; 最终整数部分在ECX:EAX，但ECX应该为0
    MOV Z_INT, EAX
    MOV EAX, EDX
    LEA DI, Z_FRACTIONAL
    CALL CONVERT_NUM_TO_FRAC
    JMP DIV_DONE_ACCURATE
    
HANDLE_LARGE_QUOTIENT:
    ; 商超过64位，需要特殊处理
    ; 这里简化处理：显示错误或使用最大值
    MOV Z_INT, 0FFFFFFFFh
    LEA DI, Z_FRACTIONAL
    MOV CX, 8
    MOV AL, '9'
LARGE_QUOTIENT_LOOP:
    MOV [DI], AL
    INC DI
    LOOP LARGE_QUOTIENT_LOOP
    
DIV_DONE_ACCURATE:

    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
ACCURATE_DIVIDE ENDP


;128位除以64位除法
DIVIDE_128_BY_64_ACCURATE PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    ; 初始化128位商
    MOV DWORD PTR QUOTIENT_0, 0
    MOV DWORD PTR QUOTIENT_1, 0
    MOV DWORD PTR QUOTIENT_2, 0
    MOV DWORD PTR QUOTIENT_3, 0
    
    ; 初始化128位余数
    MOV DWORD PTR REMAINDER_32, 0
    XOR EDI, EDI              ; 余数高位
    XOR ESI, ESI              ; 余数低位
    
    ; 循环128次（处理128位商）
    MOV ECX, 127
    
DIV_LOOP_ACCURATE:
    ; 将128位被除数左移1位
    SHL DWORD PTR PRODUCT128_0, 1
    RCL DWORD PTR PRODUCT128_1, 1
    RCL DWORD PTR PRODUCT128_2, 1
    RCL DWORD PTR PRODUCT128_3, 1
    
    ; 将移出的位放入余数
    RCL ESI, 1
    RCL EDI, 1
    
    ; 检查余数是否 >= 除数
    MOV EAX, EDI
    CMP EAX, DWORD PTR TEMP_Y_HIGH
    JB NO_SUBTRACT_ACCURATE
    JA DO_SUBTRACT_ACCURATE
    MOV EAX, ESI
    CMP EAX, DWORD PTR TEMP_Y_LOW
    JB NO_SUBTRACT_ACCURATE
    
DO_SUBTRACT_ACCURATE:
    ; 执行减法：余数 - 除数
    MOV EAX, ESI
    SUB EAX, DWORD PTR TEMP_Y_LOW
    MOV ESI, EAX
    MOV EAX, EDI
    SBB EAX, DWORD PTR TEMP_Y_HIGH
    MOV EDI, EAX
    
    ; 设置商的最低位为1
    OR DWORD PTR QUOTIENT_0, 1
    
NO_SUBTRACT_ACCURATE:
    ; 将128位商左移1位
    SHL DWORD PTR QUOTIENT_0, 1
    RCL DWORD PTR QUOTIENT_1, 1
    RCL DWORD PTR QUOTIENT_2, 1
    RCL DWORD PTR QUOTIENT_3, 1
    
    LOOP DIV_LOOP_ACCURATE
    
    ; 存储最终的余数
    MOV DWORD PTR REMAINDER_32, ESI
    
    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
DIVIDE_128_BY_64_ACCURATE ENDP




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;PRODUCT128/1e8 =QUOTIENT_1 QUOTIENT_0  REMAINDER_32
; 安全的128位除以1e8 
DIVIDE_128_BY_1E8_SAFE PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    PUSH EDI
    
    MOV ECX, 128              ; 128次循环
    MOV EBX, 200000000        ; 除数
    
    ; 初始化64位商
    MOV DWORD PTR QUOTIENT_0, 0
    MOV DWORD PTR QUOTIENT_1, 0
    
    ; 初始化余数为0
    XOR EDI, EDI              ; EDI = 余数
    
DIV_LOOP_128:
    ; 将128位被除数左移1位到余数中
    SHL DWORD PTR PRODUCT128_0, 1
    RCL DWORD PTR PRODUCT128_1, 1
    RCL DWORD PTR PRODUCT128_2, 1
    RCL DWORD PTR PRODUCT128_3, 1
    RCL EDI, 1                ; 余数也左移，最低位来自PRODUCT128_3的最高位
    
    ; 检查余数是否 >= 除数
    MOV EAX, EDI
    CMP EAX, EBX
    JB MUL_NO_SUBTRACT
    
    ; 减去除数
    SUB EAX, EBX
    MOV EDI, EAX              ; 更新余数
    
    ; 设置商的最低位为1
    OR DWORD PTR QUOTIENT_0, 1
    
MUL_NO_SUBTRACT:
    ; 将64位商左移1位
    SHL DWORD PTR QUOTIENT_0, 1
    RCL DWORD PTR QUOTIENT_1, 1
    
    LOOP DIV_LOOP_128
    
    ; 最后的余数存储在REMAINDER_32中（如果需要的话）
    MOV DWORD PTR REMAINDER_32, EDI
    
    POP EDI
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
DIVIDE_128_BY_1E8_SAFE ENDP


; 将小数字符串转换为数值
; 输入: SI指向8字符字符串
; 输出: EAX = 数值
CONVERT_FRAC_TO_NUM PROC NEAR
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH SI
    
    XOR EAX, EAX
    MOV ECX, 8
    
CONVERT_LOOP:
    MOV BL, [SI]
    SUB BL, '0'
    MOVZX EBX, BL
    
    MOV EDX, 10
    MUL EDX
    ADD EAX, EBX
    
    INC SI
    LOOP CONVERT_LOOP
    
    POP SI
    POP EDX
    POP ECX
    POP EBX
    RET
CONVERT_FRAC_TO_NUM ENDP

; 将数值转换为8位小数字符串
; 输入: EAX = 数值, DI指向目标字符串
CONVERT_NUM_TO_FRAC PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH DI
    
    MOV ECX, 8
    ADD DI, 7                  ; 从最后一位开始
    
CONVERT_BACK_LOOP:
    MOV EBX, 10
    XOR EDX, EDX
    DIV EBX                    ; EDX = 余数, EAX = 商
    
    ADD DL, '0'
    MOV [DI], DL
    DEC DI
    
    LOOP CONVERT_BACK_LOOP
    
    POP DI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
CONVERT_NUM_TO_FRAC ENDP

; 检查除数 Y 是否为 0
; CF = 1 → 为0
CHECK_DIVISOR_ZERO PROC NEAR
    PUSH EAX
    PUSH ECX
    PUSH SI

    MOV EAX, Y_INT
    CMP EAX, 0
    JNZ NOT_ZERO

    ; 检查 8 位小数是否全 0
    LEA SI, Y_FRACTIONAL
    MOV CX, 8
CHK_FRAC:
    CMP BYTE PTR [SI], '0'
    JNE NOT_ZERO
    INC SI
    LOOP CHK_FRAC

    STC                 ; 除数为 0
    JMP CHK_EXIT

NOT_ZERO:
    CLC

CHK_EXIT:
    POP SI
    POP ECX
    POP EAX
    RET
CHECK_DIVISOR_ZERO ENDP

; 初始化数字为0
; 输入: DI指向数字结构
INIT_ZERO PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DI
    
    MOV BYTE PTR [DI], 0          ; 符号为正
    MOV DWORD PTR [DI+1], 0       ; 整数部分为0
    
    ; 小数部分初始化为'00000000'
    MOV CX, 8
    ADD DI, 5
INIT_ZERO_LOOP:
    MOV BYTE PTR [DI], '0'
    INC DI
    LOOP INIT_ZERO_LOOP
    
    POP DI
    POP CX
    POP AX
    RET
INIT_ZERO ENDP

; 交换两个数字结构
SWAP_NUMBERS PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH CX
    PUSH SI
    PUSH DI
    
    ; 交换符号
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    
    ; 交换整数部分
    MOV EAX, [SI+1]
    MOV EBX, [DI+1]
    MOV [SI+1], EBX
    MOV [DI+1], EAX
    
    ; 交换小数部分
    MOV CX, 8
    ADD SI, 5
    ADD DI, 5
SWAP_FRAC:
    MOV AL, [SI]
    MOV BL, [DI]
    MOV [SI], BL
    MOV [DI], AL
    INC SI
    INC DI
    LOOP SWAP_FRAC
    
    POP DI
    POP SI
    POP CX
    POP EBX
    POP EAX
    RET
SWAP_NUMBERS ENDP

;换行
;不明错误：直接用09H，用字符串换行无法实现“回车”，只能“换行”，排除$问题
PRINT_NEWLINE PROC NEAR
    PUSH AX
    PUSH DX
    
    MOV AH, 02h
    MOV DL, 0Dh    ; 回车
    INT 21h
    MOV DL, 0Ah    ; 换行
    INT 21h
    
    POP DX
    POP AX
    RET
PRINT_NEWLINE ENDP

CODE ENDS
END START 