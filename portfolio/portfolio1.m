clear all; close all; clc; %초기화

%%%%%% 초반 작업

%       path = uigetdir('시작경로', '타이틀');       폴더의 경로를 특정 변수 path 로 지정.
%       pathIm = inptdlg('내용', '타이틀', 라인 숫자, {'초기숫자'});       내용을 입력받아 변수 pathIm에 저장
%       'pathIm'.jpg 를 다시 변수 pathIm에 저장
%       I : 읽은 이미지 변수.
%       [R, C, X] = [이미지의 Row size, Column size, channel]
%       I1 : grayscale화된 I
path = uigetdir('c:\', '사진이 있는 폴더를 지정해주세요');
pathIm = inputdlg('파일 명을 확장자 빼고 입력 해주세요.', '파일 지정', 1, {'1'});
pathIm = strcat(path, '\', char(pathIm), '.jpg');
I=imread(pathIm); % 이미지 읽음
%figure(1); imshow(I);
[R,C,X]=size(I); % 이미지 사이즈 저장
I1=rgb2gray(I);  % gray스케일로 변환
%figure(2); imshow(I1);
%%%%%% 여기까지 초반 작업

%%%%%%%%%%%%%%%%%%%% morphology 작업

%       주 작업 : 열림, 붙임, 붙임-열림, 평균 필터링, 이진화, 불림, 녹임
%       I2 : 열림, I3 : 붙임, I4 : 붙임-열림, I5 : 평균 필터링 -> 이진화
%       I6 : 불림 -> 녹임,
I2=imopen(I1,ones(20,50)); % 열림연산 수행
%figure(3); imshow(I2);
I3=imclose(I1,ones(8,70)); % 붙임 연산 수행
%figure(4); imshow(I3);
I4=imsubtract(I3, I2); % 붙임연산-열림연산
%figure(5); imshow(I4);
f=fspecial('average');
I5=filter2(f,I4);           % 평균 필터링 수행
%figure(6); imshow(uint8(I5));

%%%%%%%%%%%%%% 이진화 작업
SImage=size(I5);
for i = 1 : SImage(1,1)
    for j = 1 : SImage(1,2) 
        if ( 70 >= I5(i,j)) % 한 지점의 픽셀값이 70보다 작거나 같을 시
            I5(i,j) = 0; % 검정색
        else % 한 지점의 픽셀값이 70보다 클 시
            I5(i,j) = 255; % 흰색
        end
    end
end
%%%%%%%%%%%%%% 여기까지 이진화
%figure(7); imshow(I5);

I6=imdilate(I5,ones(18,18)); % 번호판 영역에 생길 수 있는 문제를 해결하기 위한 불림
%figure(8); imshow(I6);
I6=imerode(I5,ones(10,10));
%figure(8); imshow(I6);
%%%%%%%%%%%%%%%%%%%%%% 여기까지 morphology 작업

%%%%%%%%%%%%%번호판 선정 작업

%       각 영역을 bwlabel로 나눔
%       나뉜 각 영역의 Row/Column size, 각 영역의 크기를 double/cell type으로 저장.

%       영역을 찾기 위한 조건 설정
%       1. Row<Column
%       2. Row의 최소값 > 전체 이미지 Row값*0.5
%       => 두 조건에 안 맞는 영역은 검게 함.
%       3. 거른 영역 중 크기가 가장 큰 영역.
%       => 원본 이미지 변수 I에서 새로운 변수 Im 으로 해당 영역만 잘라서 저장
[L, num]=bwlabel(I6,8); % 각 영역 라벨링

SImage1=size(L);

%%%%%%%%% 각 후보군 영역의 정보를 얻기 위한 작업
for i = 1:num
    [row{i}, col{i}] = find(L == i); % 각 후보군 영역의 row와 column 정보를 저장
    Rmin{i} = min(row{i}); 
    Rmax{i} = max(row{i});
    Cmin{i} = min(col{i});
    Cmax{i} = max(col{i});
    Rsize{i} = Rmax{i}-Rmin{i}; % 각 후보군 영역의 Row size 저장
    Csize{i} = Cmax{i}-Cmin{i}; % 각 후보군 영역의 Column size 저장
    Size(i) = numel(find(L==i));   % 각 후보군 영역의 크기를 계산
    Size1{i} = numel(find(L==i));   % 각 후보군 영역의 크기를 계산하여 cell type으로 저장
end
%%%%%%%%% 여기까지 정보 수집 작업

%%%%%%%%% 얻은 정보를 토대로 번호판 영역을 찾기 위한 조건 설정 작업
for i = 1:num
    if Rsize{i}>Csize{i}            % 각 후보 영역의 row 길이가 column 길이보다 작아야함
        Size1{i}=0;
        Size(i)=0;
    else
        if Rmin{i}<0.5*R
            Size1{i}=0;
            Size(i)=0;              % 각 후보 영역의 row 최소값이 전체 이미지의
                                    % 0.55*(row size) 보다 커야함
                                    % = 전체 이미지의 절반 아랫부분만 search
    % 위 두 조건에 맞지 않는 영역의 값들을 0으로 만듬 (=검게 칠함)
        else
            if Size1{i} == max(Size)   % 위의 조건에서 거른 후보군 영역들중 제일 큰 영역을 선정
                disp('번호판으로 추정되는 영역을 찾았습니다.')
                %sprintf('번호판으로 추정되는 영역은 %d영역입니다', i)
                N=i;
            end
        end
    end
end
%%%%%%%%% 여기까지 조건을 토대로 번호판 선정

Im = imcrop(I, [Cmin{N} Rmin{N} Csize{N} Rsize{N}]);    % 번호판 영역을 자름
figure(11); imshow(Im);
%%%%%%%%%%%%% 여기까지 번호판 선정 작업

%%%%%%%%%%%%% 번호판 분류 작업

%       [RowIm, ColIm, C] = [Im의 Row size, Column size, channel]
%       Im의 전체 평균값 Immean 생성.

%       저장한 size 정보를 이용해 조건을 설정하여
%       1. 규격을 먼저 구분하고(김, 짧음) 그에 맞게 morphology 작업 수행
%       2. 짧은 것 중 흰색, 녹색 구분하기 위해 Immean 이용 -> 색 구분
[RowIm ColIm C]=size(Im);        
Immean = mean2(Im);
%%%%%%% 자른 영역의 row와 column size를 이용해 번호판을 구분한다.
if RowIm*3<ColIm
    disp('규격 : 김')
    Imlong=Im;
    Im2 = rgb2gray(Imlong);
    Im3 = imclose(Im2, ones(20,50));
    Im4 = Im3-Im2;      % 신형의 경우 번호판에 비해 문자부분이 어두운 색이다.
else
    disp('규격 : 짧음')
    Imshort=Im;
    Im2 = rgb2gray(Imshort);
    Im3 = imopen(Im2, ones(20,50));
    Im4 = Im2-Im3;      % 구형의 경우 번호판에 비해 문자부분이 밝은 색이다
end
%%%%%%% 번호판의 종류에 따라 Im4가 달라진다.

if Immean<110
    disp('원본영상이 흑백이므로 번호판의 색을 알 수 없습니다.')
elseif Immean>170
        disp('번호판의 색 : 흰색')
    else
        disp('번호판의 색 : 녹색')
end
%%%%%%%%%%%%% 여기까지 번호판 분류 작업

%%%%%%%%%%%%% 문자 추출 작업

%       Im4를 이진화 한 뒤 bwlabel을 이용해 구분한다.
%       이후 위의 번호판 선정 때 처럼 각 정보를 수집한 뒤
%       지나치게 크거나 작은 영역(잡영으로 여김) 을 0으로 만든다.
%       이후 0으로 만든 부분을 제외한 집합을 subplot을 이용해 출력
SImage2=size(Im4);
for i = 1 : SImage2(1,1)
    for j = 1 : SImage2(1,2) 
        if ( 70 >= Im4(i,j)) % 한 지점의 픽셀값이 70보다 작거나 같을 시
            Im4(i,j) = 0; % 검정색
        else % 한 지점의 픽셀값이 70보다 클 시
            Im4(i,j) = 255; % 흰색
        end
    end
end


%figure(12); imshow(Im4);
[L1, num1]=bwlabel(Im4,8); % 각 영역 라벨링
k=1;
SImage4=size(L1);
for i = 1:num1
    [row1{i}, col1{i}] = find(L1 == i); % 각 문자 영역의 row와 column 정보를 저장
    Rmin1{i} = min(row1{i}); 
    Rmax1{i} = max(row1{i});
    Cmin1{i} = min(col1{i});
    Cmax1{i} = max(col1{i});
    Rsize1{i} = Rmax1{i}-Rmin1{i}; % 각 문자 영역의 Row size 저장
    Csize1{i} = Cmax1{i}-Cmin1{i}; % 각 문자 영역의 Column size 저장
    Size2(i) = numel(find(L1==i));   % 각 문자 영역의 크기를 계산
    Size22{i} = numel(find(L1==i));   % 각 문자 영역의 크기를 계산하여 cell type으로 저장
    if Size22{i} < 100
        Size22{i}=0;
        Size2(i)=0;     % 매우 작은 영역들의 값들은 0으로 만든다.
    elseif Size22{i} > 2100
        Size22{i}=0;
        Size2(i)=0;     % 지나치게 큰 영역들의 값도 0으로 만든다.
    else
        if Size22{i}~=0
        Image{k} = imcrop(L1, [Cmin1{i} Rmin1{i} Csize1{i} Rsize1{i}]);
        k=k+1;      % 0으로 만든 영역을 제외하고 Image 라는 행렬에 저장한다.
        else
        end
    end
end

for i=1:k-1
    figure(13); subplot(1,k,i); imshow(Image{i});
end

%%%%%%%%%%%%% 여기까지 문자 추출 작업