# Project Gravity

1698109508

## Introducing Project Gravity

<a href='https://projectgravity.io' target="_blank" class="text-black dark:text-neutral">Project Gravity</a> hosts <a href='https://projectgravity.io/chat' target="_blank" class="text-black dark:text-neutral">SoftLandingGPT</a>, an AI-enabled librarian for resources aimed at empowering bystanders to engage with people who may be falling down paths towards radicalization. The goal is to reach out to service providers like school counselors and community leaders to help connect them to the resources available in the countering targeted violence space.

## Components

As Tech Lead, I was in charge of implementing everything. From the interface with OpenAI's API, to <a href='https://huggingface.co/moonstripe/hate_speech_classification_v1' target="_blank" class="text-black dark:text-neutral">building custom moderation models on huggingface</a>, this is definitely my most ambitious web-hosted software project yet. I wanted to go over the major features I've implemented in the last month.

### AI-enabled, natural language directory

The centerpiece of <a href='https://projectgravity.io' target="_blank" class="text-black dark:text-neutral">Project Gravity</a> is our <a href='https://projectgravity.io/chat' target="_blank" class="text-black dark:text-neutral">SoftLandignGPT</a> tool. Presented like an online chat, it pulls together resources we've found that might help equip a person who is unsure of how to engage with a loved one who is falling down a conspiracy rabbit hole. It uses websockets to connect with our backend, which interfaces with OpenAI's API. The conversation is preceded by several system prompts that give GPT-3.5 a more defined role, and equip it with research and resources that are pulled together by our team.

### Custom hate speech classifier

After testing OpenAI's moderation endpoint, it became clear that we had more narrow requirements for a hate speech classifier. This triggers our "traffic light" system, in which we flag conversations as green, yellow, or red for internal review. So I trained a BERT model for four days on the <a href='https://huggingface.co/datasets/ucberkeley-dlab/measuring-hate-speech' target="_blank" class="text-black dark:text-neutral">measuring hate dataset provided by UC Berkeley's D-lab</a>, to create <a href='https://huggingface.co/moonstripe/hate_speech_classification_v1' target="_blank" class="text-black dark:text-neutral">our custom model</a>. This was the first model I've ever trained from scratch and deployed on huggingface. We hope that by providing it with an open license for use, we demonstrate how committed we are to pushing the envelope for developing tools that can be used to counter targeted violence.

### Content management by Sanity

Once again, <a href='https://www.sanity.io/' target="_blank" class="text-black dark:text-neutral">Sanity</a> comes to the rescue. Everything from our <a href='https://projectgravity.io/blog' target="_blank" class="text-black dark:text-neutral">blog</a>, to our <a href='https://projectgravity.io/research' target="_blank" class="text-black dark:text-neutral">research citations</a> page, to the deployed resources, is hosted on Sanity, which allows for the whole team to get involved without pinging me everytime they find a new resource. It's incredible uptime, quick response, and incredible pricing plan made it a no brainer to integrate into the project. **Thank you, Sanity!**

### Admin Dashboard

Though definitely a long-term goal, we want to aggregate important natural language trends from our conversations without breaching our privacy priority. With Google-based OAuth, team members can glean essential top level statistics and get key summaries from the database without messing with the database itself.

### Custom link tracking

Suggested to us by our friends at the McCain Institute, I implemented a custom link passthrough service that counts all of the outbound links provided by our tool. This will help us spin up a business model, and demonstrate our value to our partners through hard data.

## Try it out and tell me what you think!

I've had a blast implementing everything, but this isn't just a portfolio project. This is something that we think really has legs, and might turn into something much bigger than an Invent2Prevent competition entry. I'm honored to have had an integral part in building <a href='https://projectgravity.io' target="_blank" class="text-black dark:text-neutral">Project Gravity</a>, and I hope you see the vision, too.