# ----------------------------------------
# NHN Cloud 보안 파이프라인 샘플 Dockerfile
# 보안 베스트 프랙티스 적용
# ----------------------------------------

# 1. 공식 경량 Nginx 이미지 사용
FROM nginx:1.25-alpine

# 2. 이미지 메타데이터
LABEL maintainer="security@yourcompany.com"
LABEL version="1.0.0"
LABEL description="NHN Cloud CWPP 보안 파이프라인 샘플 앱"

# 3. 불필요한 패키지 제거 및 보안 업데이트
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# 4. non-root 유저 생성 (보안 강화)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# 5. 기본 Nginx 설정 제거 후 보안 설정 적용
RUN rm -rf /usr/share/nginx/html/*

# 6. 앱 파일 복사 (소유권 명시)
COPY --chown=appuser:appgroup index.html /usr/share/nginx/html/

# 7. Nginx 보안 설정 (server_tokens 숨김)
RUN echo 'server_tokens off;' > /etc/nginx/conf.d/security.conf

# 8. 포트 노출
EXPOSE 80

# 9. 헬스체크 설정
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# 10. Nginx 실행
CMD ["nginx", "-g", "daemon off;"]
