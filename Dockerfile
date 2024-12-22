FROM ruby:3.2.2-slim

# Install essential Linux packages, yt-dlp, and ffmpeg
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    nodejs \
    python3-full \
    python3-pip \
    ffmpeg \
    && pip3 install --break-system-packages yt-dlp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY Gemfile* .
RUN bundle install
COPY . .

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
