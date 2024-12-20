FROM node:20.11.1

# See https://blog.apify.com/puppeteer-docker/
# Split commands to profit of caching steps

# Install the latest Chrome dev package and necessary fonts and libraries
RUN apt-get update
RUN apt-get install -y wget gnupg
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] https://dl-ssl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list
RUN apt-get update
RUN apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 dbus dbus-x11 --no-install-recommends
RUN rm -rf /var/lib/apt/lists/*

RUN useradd -rm -G audio,video tarc-pdf

# Switch to the non-root user
USER tarc-pdf

# Set the working directory
WORKDIR /home/tarc-pdf

# Copy package.json and package-lock.json
COPY --chown=tarc-pdf:tarc-pdf package*.json ./

# Install Puppeteer without downloading bundled Chromium
RUN npm install puppeteer --no-save

# Copy your Puppeteer script into the Docker image
COPY --chown=tarc-pdf:tarc-pdf . .

# Update the PUPPETEER_EXECUTABLE_PATH to the correct chrome path (placeholder, update based on the output of `which google-chrome-stable`)
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# This is the port on which service.js listens
EXPOSE 8080

# Set the command to run your puppeteer script
CMD ["node", "service.js"]
