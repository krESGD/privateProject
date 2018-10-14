clear all; close all; clc; %�ʱ�ȭ

%%%%%% �ʹ� �۾�

%       path = uigetdir('���۰��', 'Ÿ��Ʋ');       ������ ��θ� Ư�� ���� path �� ����.
%       pathIm = inptdlg('����', 'Ÿ��Ʋ', ���� ����, {'�ʱ����'});       ������ �Է¹޾� ���� pathIm�� ����
%       'pathIm'.jpg �� �ٽ� ���� pathIm�� ����
%       I : ���� �̹��� ����.
%       [R, C, X] = [�̹����� Row size, Column size, channel]
%       I1 : grayscaleȭ�� I
path = uigetdir('c:\', '������ �ִ� ������ �������ּ���');
pathIm = inputdlg('���� ���� Ȯ���� ���� �Է� ���ּ���.', '���� ����', 1, {'1'});
pathIm = strcat(path, '\', char(pathIm), '.jpg');
I=imread(pathIm); % �̹��� ����
%figure(1); imshow(I);
[R,C,X]=size(I); % �̹��� ������ ����
I1=rgb2gray(I);  % gray�����Ϸ� ��ȯ
%figure(2); imshow(I1);
%%%%%% ������� �ʹ� �۾�

%%%%%%%%%%%%%%%%%%%% morphology �۾�

%       �� �۾� : ����, ����, ����-����, ��� ���͸�, ����ȭ, �Ҹ�, ����
%       I2 : ����, I3 : ����, I4 : ����-����, I5 : ��� ���͸� -> ����ȭ
%       I6 : �Ҹ� -> ����,
I2=imopen(I1,ones(20,50)); % �������� ����
%figure(3); imshow(I2);
I3=imclose(I1,ones(8,70)); % ���� ���� ����
%figure(4); imshow(I3);
I4=imsubtract(I3, I2); % ���ӿ���-��������
%figure(5); imshow(I4);
f=fspecial('average');
I5=filter2(f,I4);           % ��� ���͸� ����
%figure(6); imshow(uint8(I5));

%%%%%%%%%%%%%% ����ȭ �۾�
SImage=size(I5);
for i = 1 : SImage(1,1)
    for j = 1 : SImage(1,2) 
        if ( 70 >= I5(i,j)) % �� ������ �ȼ����� 70���� �۰ų� ���� ��
            I5(i,j) = 0; % ������
        else % �� ������ �ȼ����� 70���� Ŭ ��
            I5(i,j) = 255; % ���
        end
    end
end
%%%%%%%%%%%%%% ������� ����ȭ
%figure(7); imshow(I5);

I6=imdilate(I5,ones(18,18)); % ��ȣ�� ������ ���� �� �ִ� ������ �ذ��ϱ� ���� �Ҹ�
%figure(8); imshow(I6);
I6=imerode(I5,ones(10,10));
%figure(8); imshow(I6);
%%%%%%%%%%%%%%%%%%%%%% ������� morphology �۾�

%%%%%%%%%%%%%��ȣ�� ���� �۾�

%       �� ������ bwlabel�� ����
%       ���� �� ������ Row/Column size, �� ������ ũ�⸦ double/cell type���� ����.

%       ������ ã�� ���� ���� ����
%       1. Row<Column
%       2. Row�� �ּҰ� > ��ü �̹��� Row��*0.5
%       => �� ���ǿ� �� �´� ������ �˰� ��.
%       3. �Ÿ� ���� �� ũ�Ⱑ ���� ū ����.
%       => ���� �̹��� ���� I���� ���ο� ���� Im ���� �ش� ������ �߶� ����
[L, num]=bwlabel(I6,8); % �� ���� �󺧸�

SImage1=size(L);

%%%%%%%%% �� �ĺ��� ������ ������ ��� ���� �۾�
for i = 1:num
    [row{i}, col{i}] = find(L == i); % �� �ĺ��� ������ row�� column ������ ����
    Rmin{i} = min(row{i}); 
    Rmax{i} = max(row{i});
    Cmin{i} = min(col{i});
    Cmax{i} = max(col{i});
    Rsize{i} = Rmax{i}-Rmin{i}; % �� �ĺ��� ������ Row size ����
    Csize{i} = Cmax{i}-Cmin{i}; % �� �ĺ��� ������ Column size ����
    Size(i) = numel(find(L==i));   % �� �ĺ��� ������ ũ�⸦ ���
    Size1{i} = numel(find(L==i));   % �� �ĺ��� ������ ũ�⸦ ����Ͽ� cell type���� ����
end
%%%%%%%%% ������� ���� ���� �۾�

%%%%%%%%% ���� ������ ���� ��ȣ�� ������ ã�� ���� ���� ���� �۾�
for i = 1:num
    if Rsize{i}>Csize{i}            % �� �ĺ� ������ row ���̰� column ���̺��� �۾ƾ���
        Size1{i}=0;
        Size(i)=0;
    else
        if Rmin{i}<0.5*R
            Size1{i}=0;
            Size(i)=0;              % �� �ĺ� ������ row �ּҰ��� ��ü �̹�����
                                    % 0.55*(row size) ���� Ŀ����
                                    % = ��ü �̹����� ���� �Ʒ��κи� search
    % �� �� ���ǿ� ���� �ʴ� ������ ������ 0���� ���� (=�˰� ĥ��)
        else
            if Size1{i} == max(Size)   % ���� ���ǿ��� �Ÿ� �ĺ��� �������� ���� ū ������ ����
                disp('��ȣ������ �����Ǵ� ������ ã�ҽ��ϴ�.')
                %sprintf('��ȣ������ �����Ǵ� ������ %d�����Դϴ�', i)
                N=i;
            end
        end
    end
end
%%%%%%%%% ������� ������ ���� ��ȣ�� ����

Im = imcrop(I, [Cmin{N} Rmin{N} Csize{N} Rsize{N}]);    % ��ȣ�� ������ �ڸ�
figure(11); imshow(Im);
%%%%%%%%%%%%% ������� ��ȣ�� ���� �۾�

%%%%%%%%%%%%% ��ȣ�� �з� �۾�

%       [RowIm, ColIm, C] = [Im�� Row size, Column size, channel]
%       Im�� ��ü ��հ� Immean ����.

%       ������ size ������ �̿��� ������ �����Ͽ�
%       1. �԰��� ���� �����ϰ�(��, ª��) �׿� �°� morphology �۾� ����
%       2. ª�� �� �� ���, ��� �����ϱ� ���� Immean �̿� -> �� ����
[RowIm ColIm C]=size(Im);        
Immean = mean2(Im);
%%%%%%% �ڸ� ������ row�� column size�� �̿��� ��ȣ���� �����Ѵ�.
if RowIm*3<ColIm
    disp('�԰� : ��')
    Imlong=Im;
    Im2 = rgb2gray(Imlong);
    Im3 = imclose(Im2, ones(20,50));
    Im4 = Im3-Im2;      % ������ ��� ��ȣ�ǿ� ���� ���ںκ��� ��ο� ���̴�.
else
    disp('�԰� : ª��')
    Imshort=Im;
    Im2 = rgb2gray(Imshort);
    Im3 = imopen(Im2, ones(20,50));
    Im4 = Im2-Im3;      % ������ ��� ��ȣ�ǿ� ���� ���ںκ��� ���� ���̴�
end
%%%%%%% ��ȣ���� ������ ���� Im4�� �޶�����.

if Immean<110
    disp('���������� ����̹Ƿ� ��ȣ���� ���� �� �� �����ϴ�.')
elseif Immean>170
        disp('��ȣ���� �� : ���')
    else
        disp('��ȣ���� �� : ���')
end
%%%%%%%%%%%%% ������� ��ȣ�� �з� �۾�

%%%%%%%%%%%%% ���� ���� �۾�

%       Im4�� ����ȭ �� �� bwlabel�� �̿��� �����Ѵ�.
%       ���� ���� ��ȣ�� ���� �� ó�� �� ������ ������ ��
%       ����ġ�� ũ�ų� ���� ����(�⿵���� ����) �� 0���� �����.
%       ���� 0���� ���� �κ��� ������ ������ subplot�� �̿��� ���
SImage2=size(Im4);
for i = 1 : SImage2(1,1)
    for j = 1 : SImage2(1,2) 
        if ( 70 >= Im4(i,j)) % �� ������ �ȼ����� 70���� �۰ų� ���� ��
            Im4(i,j) = 0; % ������
        else % �� ������ �ȼ����� 70���� Ŭ ��
            Im4(i,j) = 255; % ���
        end
    end
end


%figure(12); imshow(Im4);
[L1, num1]=bwlabel(Im4,8); % �� ���� �󺧸�
k=1;
SImage4=size(L1);
for i = 1:num1
    [row1{i}, col1{i}] = find(L1 == i); % �� ���� ������ row�� column ������ ����
    Rmin1{i} = min(row1{i}); 
    Rmax1{i} = max(row1{i});
    Cmin1{i} = min(col1{i});
    Cmax1{i} = max(col1{i});
    Rsize1{i} = Rmax1{i}-Rmin1{i}; % �� ���� ������ Row size ����
    Csize1{i} = Cmax1{i}-Cmin1{i}; % �� ���� ������ Column size ����
    Size2(i) = numel(find(L1==i));   % �� ���� ������ ũ�⸦ ���
    Size22{i} = numel(find(L1==i));   % �� ���� ������ ũ�⸦ ����Ͽ� cell type���� ����
    if Size22{i} < 100
        Size22{i}=0;
        Size2(i)=0;     % �ſ� ���� �������� ������ 0���� �����.
    elseif Size22{i} > 2100
        Size22{i}=0;
        Size2(i)=0;     % ����ġ�� ū �������� ���� 0���� �����.
    else
        if Size22{i}~=0
        Image{k} = imcrop(L1, [Cmin1{i} Rmin1{i} Csize1{i} Rsize1{i}]);
        k=k+1;      % 0���� ���� ������ �����ϰ� Image ��� ��Ŀ� �����Ѵ�.
        else
        end
    end
end

for i=1:k-1
    figure(13); subplot(1,k,i); imshow(Image{i});
end

%%%%%%%%%%%%% ������� ���� ���� �۾�