# Caster
Mobile app for content creators, field authorities, e-learning teachers, tutors or podcasters in general looking to stablish your own community outside major distribution platforms.

![Hausmeister](./caster-1.jpeg)

### Features
- Auto loading episodes with RSS feed consumption
- Background player 
- Downloadable episodes 
- User accounts
- Chat threads
- Image sharing in Threads


### Next steps with Deploid Studio
Sell subscription plans and enable paid content directly within your app with Stripe payment processing

### Development

Change RSS feed
Update `podcast_rss_feed_string` from `app/lib/includes/default.dart`

Build container
`docker-compose build --build-arg EMULATOR_HOST=localhost`

Start container
`docker-compose up`

Run app
`flutter run --dart-define=EMULATOR_HOST=0.0.0.0`

Setup Firebase
```bash
firebase init
cd app && flutterfire configure
```
