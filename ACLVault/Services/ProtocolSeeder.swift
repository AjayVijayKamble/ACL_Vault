//
//  ProtocolSeeder.swift
//  ACLVault
//
//  Initial Database Seeder: 10 Levels, 30+ Medical Exercises & Mock Historical Logs
//

import Foundation
import SwiftData

@MainActor
public enum ProtocolSeeder {
    
    public static func seedInitialDataIfNeeded(context: ModelContext) {
        // Check if Exercises already seeded
        let exerciseDescriptor = FetchDescriptor<Exercise>()
        let existingExercises = (try? context.fetch(exerciseDescriptor)) ?? []
        
        if existingExercises.isEmpty {
            seedExercises(context: context)
        }
        
        // Check if UserProfile exists; if not, create default
        let profileDescriptor = FetchDescriptor<UserProfile>()
        let existingProfiles = (try? context.fetch(profileDescriptor)) ?? []
        
        if existingProfiles.isEmpty {
            let defaultProfile = UserProfile(
                name: "Alex Vance",
                surgeryDate: Calendar.current.date(byAdding: .day, value: -26, to: Date()) ?? Date(),
                rehabStage: .postOp,
                graftType: .patellar,
                meniscusRepair: false,
                injuredSide: .right,
                currentLevel: 2,
                isProSubscriber: false,
                hasCompletedOnboarding: true
            )
            context.insert(defaultProfile)
            
            // Seed 30-day realistic progression for charts & analytics
            seedHistoricalROMAndCheckIns(context: context, profile: defaultProfile)
            seedSampleWorkoutLogs(context: context)
        }
        
        try? context.save()
    }
    
    // MARK: - 30 Comprehensive ACL Rehabilitation Exercises
    private static func seedExercises(context: ModelContext) {
        let exercises: [Exercise] = [
            // Level 1: Terminal Extension & Quiet the Knee
            Exercise(
                title: "Quad Sets (Isometric VMO Contraction)",
                levelRequired: 1,
                category: .quadActivation,
                defaultSets: 3,
                defaultReps: 15,
                holdSeconds: 10,
                formCues: [
                    "Sit with injured leg extended flat on floor or treatment table.",
                    "Roll a small washcloth under the ankle to elevate the heel 1 inch.",
                    "Actively drive the back of the knee straight down into the mat.",
                    "Squeeze your quad muscle with maximal voluntary effort. Your heel should elevate off the surface.",
                    "Maintain steady diaphragmatic breathing—do not hold your breath during the 10-second hold."
                ],
                videoPlaceholderSymbol: "bolt.fill",
                isRegressionExercise: false,
                targetMuscle: "Vastus Medialis Oblique (VMO)",
                clinicalRationale: "Essential for overcoming arthrogenic muscle inhibition (AMI) and restoring active terminal extension."
            ),
            Exercise(
                title: "Prone Hangs (Passive Gravity Extension)",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 1,
                holdSeconds: 120,
                formCues: [
                    "Lie face down on a bed or table with your lower thighs supported and your knees/shins hanging off the edge.",
                    "Allow gravity to pull the lower legs down into terminal knee extension.",
                    "Completely relax all thigh muscles; do not resist the stretch.",
                    "If tolerated, hang a 1–2 lb ankle weight across the Achilles tendon for low-load, long-duration stretch."
                ],
                videoPlaceholderSymbol: "arrow.down.to.line.compact",
                isRegressionExercise: false,
                targetMuscle: "Posterior Capsule & Hamstring Tendons",
                clinicalRationale: "Low-load long-duration (LLLD) stretch prevents arthrofibrosis and anterior shelf cyclops lesion."
            ),
            Exercise(
                title: "Heel Props (Passive Terminal Extension)",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 1,
                holdSeconds: 300,
                formCues: [
                    "Lie flat on your back with a firm foam roller or rolled towel placed under the ankle.",
                    "Ensure there is nothing under the knee itself.",
                    "Allow gravity to gently pull the knee down into hyperextension matching your uninjured side.",
                    "Perform while icing to manage pain and promote relaxation."
                ],
                videoPlaceholderSymbol: "figure.cross.curls",
                isRegressionExercise: true,
                targetMuscle: "Posterior Knee Joint Capsule",
                clinicalRationale: "Regaining symmetrical terminal extension is the #1 predictor of long-term joint health and normal walking mechanics."
            ),
            Exercise(
                title: "Seated Heel Slides with Strap",
                levelRequired: 1,
                category: .flexionGain,
                defaultSets: 3,
                defaultReps: 12,
                holdSeconds: 5,
                formCues: [
                    "Sit on a smooth hard floor or mat with a towel under your foot or wearing a sock.",
                    "Loop a yoga strap or belt around the midfoot.",
                    "Slowly slide your heel toward your buttocks, pulling gently with the strap at end range.",
                    "Hold at the gentle stretch barrier for 5 seconds, then slowly return to straight."
                ],
                videoPlaceholderSymbol: "arrow.up.and.down.circle",
                isRegressionExercise: false,
                targetMuscle: "Hamstrings & Joint Mobilization",
                clinicalRationale: "Gradually restores active-assisted knee flexion while protecting healing graft fixation."
            ),
            Exercise(
                title: "Straight Leg Raises (SLR) with Zero Lag",
                levelRequired: 1,
                category: .quadActivation,
                defaultSets: 3,
                defaultReps: 12,
                holdSeconds: 3,
                formCues: [
                    "Lie flat on back with uninjured knee bent and foot flat.",
                    "First, perform a maximal quad contraction to lock the operative knee completely straight (0°).",
                    "Lift the entire leg 12 inches off the floor, strictly maintaining the locked straight knee.",
                    "If the knee bends or sags (extensor lag), stop immediately and regress to quad sets."
                ],
                videoPlaceholderSymbol: "figure.walk.motion",
                isRegressionExercise: false,
                targetMuscle: "Rectus Femoris & Psoas",
                clinicalRationale: "Criterion-based milestone: 0 extensor lag during SLR is required before weaning crutches."
            ),
            Exercise(
                title: "Ankle Pumps & Circulatory Flushing",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 30,
                holdSeconds: 0,
                formCues: [
                    "Lie comfortably with legs elevated above heart level.",
                    "Vigorously point toes forward like pressing a gas pedal, then pull toes upward toward shins.",
                    "Keep moving through full ankle range of motion."
                ],
                videoPlaceholderSymbol: "arrow.clockwise.heart",
                isRegressionExercise: true,
                targetMuscle: "Gastrocnemius & Soleus (Calf Pump)",
                clinicalRationale: "Prevents Deep Vein Thrombosis (DVT) and mechanically pumps distal swelling out of the leg."
            ),
            Exercise(
                title: "Patellar Mobilizations (Multidirectional)",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 20,
                holdSeconds: 2,
                formCues: [
                    "Sit with knee supported in full extension and completely relaxed quads.",
                    "Grasp kneecap between your thumbs and index fingers.",
                    "Gently glide the patella superiorly (up toward hip), inferiorly (down), medially, and laterally.",
                    "Hold each direction for 2 seconds with mild tension."
                ],
                videoPlaceholderSymbol: "hand.tap.fill",
                isRegressionExercise: true,
                targetMuscle: "Patellofemoral Retinaculum",
                clinicalRationale: "Prevents infrapatellar fat pad scarring, patella baja, and stiff extensor mechanism."
            ),
            
            // Level 2: Normal Gait & Kinetic Chain Initiation
            Exercise(
                title: "Terminal Knee Extensions (TKE) with Band",
                levelRequired: 2,
                category: .extensionFix,
                defaultSets: 3,
                defaultReps: 15,
                holdSeconds: 2,
                formCues: [
                    "Loop a looped resistance band around a sturdy anchor and place it behind your knee joint line.",
                    "Step back to create moderate band tension with heel firmly on floor.",
                    "Start with knee bent 20°, then straighten knee against band resistance until heel locks down.",
                    "Squeeze quad intensely at full extension for 2 seconds."
                ],
                videoPlaceholderSymbol: "link",
                isRegressionExercise: false,
                targetMuscle: "VMO & Terminal Extensors",
                clinicalRationale: "Trains closed-chain knee extension in the exact angle needed for normal heel-strike gait."
            ),
            Exercise(
                title: "Wall Slides for Gravity-Assisted Flexion",
                levelRequired: 2,
                category: .flexionGain,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 5,
                formCues: [
                    "Lie on back with buttocks close to a wall, legs extended up along the wall.",
                    "Allow your surgical foot to slowly slide down the wall under gentle gravity assistance.",
                    "Use your uninjured foot placed underneath the surgical ankle to assist and support if uncomfortable."
                ],
                videoPlaceholderSymbol: "arrow.down.right.and.arrow.up.left",
                isRegressionExercise: false,
                targetMuscle: "Knee Flexors & Capsular Compliance",
                clinicalRationale: "Gravity-assisted passive flexion reduces patient guarding and builds knee flexion past 100°."
            ),
            Exercise(
                title: "Stationary Cycling (Rocking to Full Revolutions)",
                levelRequired: 2,
                category: .flexionGain,
                defaultSets: 1,
                defaultReps: 1,
                holdSeconds: 600,
                formCues: [
                    "Set bike saddle high to minimize extreme knee flexion demand initially.",
                    "Begin rocking pedals forward and backward in smooth rhythmic pendulums.",
                    "When comfortable, gently guide pedal over the top dead center for complete revolution.",
                    "Maintain zero or minimal flywheel resistance."
                ],
                videoPlaceholderSymbol: "bicycle",
                isRegressionExercise: false,
                targetMuscle: "Quadriceps, Hamstrings & Joint Synovial Pump",
                clinicalRationale: "Circulates synovial fluid to nourish cartilage, reducing swelling through continuous low-resistance cycling."
            ),
            Exercise(
                title: "Standing Bilateral Calf Raises",
                levelRequired: 2,
                category: .strength,
                defaultSets: 3,
                defaultReps: 15,
                holdSeconds: 1,
                formCues: [
                    "Stand tall lightly holding a wall or countertop for balance.",
                    "Distribute weight 50/50 evenly between both feet.",
                    "Push through big toes to rise onto the balls of your feet.",
                    "Pause for 1 second at peak, then take 3 full seconds to descend."
                ],
                videoPlaceholderSymbol: "arrow.up.circle.fill",
                isRegressionExercise: false,
                targetMuscle: "Gastrocnemius & Plantar Flexors",
                clinicalRationale: "Builds push-off power required for normal late stance gait phase."
            ),
            Exercise(
                title: "Mini Squats to 45° with Mirror Feedback",
                levelRequired: 2,
                category: .strength,
                defaultSets: 3,
                defaultReps: 12,
                holdSeconds: 2,
                formCues: [
                    "Stand facing a mirror, feet shoulder-width apart.",
                    "Hinge back at hips as if sitting into a high barstool.",
                    "Squat down only to 45° of knee bend.",
                    "Check mirror: ensure knees do not dive inward (valgus collapse)."
                ],
                videoPlaceholderSymbol: "figure.cooldown",
                isRegressionExercise: false,
                targetMuscle: "Quadriceps & Gluteus Medius",
                clinicalRationale: "Re-educates bilateral lower extremity loading and prevents knee valgus movement faults."
            ),
            
            // Level 3: Early Closed Chain & Balance
            Exercise(
                title: "Bilateral Glute Bridge Hold",
                levelRequired: 3,
                category: .strength,
                defaultSets: 3,
                defaultReps: 12,
                holdSeconds: 3,
                formCues: [
                    "Lie supine with knees bent to 90° and feet flat on floor, hip-width apart.",
                    "Drive through heels to lift hips until thighs and torso form a straight line.",
                    "Squeeze glutes hard at the apex without hyperextending lower back."
                ],
                videoPlaceholderSymbol: "figure.strengthtraining.traditional",
                isRegressionExercise: false,
                targetMuscle: "Gluteus Maximus & Hamstrings",
                clinicalRationale: "Glute strength controls hip internal rotation, which directly unloads the ACL graft."
            ),
            Exercise(
                title: "Single Leg Static Balance (Eyes Open)",
                levelRequired: 3,
                category: .balance,
                defaultSets: 3,
                defaultReps: 1,
                holdSeconds: 30,
                formCues: [
                    "Stand on surgical leg with a soft micro-bend in the knee (never locked stiff).",
                    "Keep hands on hips, level pelvis, and fix gaze on a stationary object 10 feet away.",
                    "Hold for 30 seconds without letting the opposite foot touch down."
                ],
                videoPlaceholderSymbol: "figure.gymnastics",
                isRegressionExercise: false,
                targetMuscle: "Proprioceptors & Ankle/Hip Stabilizers",
                clinicalRationale: "Restores mechanoreceptor feedback destroyed during original ACL rupture."
            ),
            Exercise(
                title: "Step-Ups on 6-Inch Platform",
                levelRequired: 3,
                category: .strength,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 1,
                formCues: [
                    "Place operative foot entirely on a 6-inch step or aerobic block.",
                    "Drive through the midfoot to elevate body into full standing position.",
                    "Do not jump or propel off the trailing foot on the ground.",
                    "Step down slowly under complete eccentric control."
                ],
                videoPlaceholderSymbol: "stairs",
                isRegressionExercise: false,
                targetMuscle: "Quadriceps & Gluteal Complex",
                clinicalRationale: "Re-establishes unilateral stair climbing capability without compensatory hip hike."
            ),
            Exercise(
                title: "Hamstring Towel Curls on Slick Floor",
                levelRequired: 3,
                category: .strength,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 2,
                formCues: [
                    "Lie on back on a wooden or tile floor with a folded towel under heels.",
                    "Bridge hips slightly up.",
                    "Dig heels into the floor and curl the towel toward your buttocks.",
                    "Slowly slide back out to starting position under control."
                ],
                videoPlaceholderSymbol: "figure.run.square.stack",
                isRegressionExercise: false,
                targetMuscle: "Biceps Femoris & Semitendinosus",
                clinicalRationale: "Active hamstring recruitment serves as the primary dynamic antagonist resisting anterior tibial translation."
            ),
            
            // Level 4: Symmetrical Hypertrophy & Joint Health
            Exercise(
                title: "Bilateral Leg Press (45° to 90° Range)",
                levelRequired: 4,
                category: .strength,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 0,
                formCues: [
                    "Sit in leg press with feet spaced shoulder-width and flat on footplate.",
                    "Slowly lower the sled until knees reach 90° flexion.",
                    "Press back up smoothly through mid-foot and heel, stopping just shy of knee lock-out."
                ],
                videoPlaceholderSymbol: "square.stack.3d.down.right.fill",
                isRegressionExercise: false,
                targetMuscle: "Quadriceps & Glutes",
                clinicalRationale: "Safely loads the patellofemoral and tibiofemoral joints with adjustable load limits."
            ),
            Exercise(
                title: "Romanian Deadlift (RDL) with Dumbbells",
                levelRequired: 4,
                category: .strength,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 1,
                formCues: [
                    "Hold light dumbbells in front of thighs, feet hip-width.",
                    "Initiate movement by pushing hips backward with a soft 15° knee bend.",
                    "Keep spine flat as dumbbells travel straight down the shins.",
                    "Drive hips forward to return to standing tall."
                ],
                videoPlaceholderSymbol: "dumbbell.fill",
                isRegressionExercise: false,
                targetMuscle: "Hamstrings, Gluteus Maximus, Erector Spinae",
                clinicalRationale: "Posterior chain hypertrophy improves deceleration ability and counteracts anterior shear."
            ),
            Exercise(
                title: "Lateral Step-Downs (Eccentric Quad Control)",
                levelRequired: 4,
                category: .strength,
                defaultSets: 3,
                defaultReps: 10,
                holdSeconds: 1,
                formCues: [
                    "Stand sideways on a 4-to-6 inch step on your surgical leg.",
                    "Slowly bend surgical knee to lower opposite heel down toward the floor.",
                    "Touch the floor lightly with the heel—do not bear weight on it.",
                    "Push through working foot to return to start position."
                ],
                videoPlaceholderSymbol: "arrow.down.right",
                isRegressionExercise: false,
                targetMuscle: "VMO & Hip Abductors",
                clinicalRationale: "Crucial clinical test: identifies subtle knee valgus or pelvic drop under eccentric load."
            ),
            Exercise(
                title: "Monster Walks with Elastic Band",
                levelRequired: 4,
                category: .strength,
                defaultSets: 3,
                defaultReps: 15,
                holdSeconds: 0,
                formCues: [
                    "Place mini resistance band just above both ankles.",
                    "Adopt an athletic quarter-squat posture with knees soft.",
                    "Take wide diagonal steps forward and outward, keeping tension on the band.",
                    "Do not allow knees to cave inward during transitional strides."
                ],
                videoPlaceholderSymbol: "figure.walk.arrival",
                isRegressionExercise: false,
                targetMuscle: "Gluteus Medius & Tensor Fasciae Latae",
                clinicalRationale: "Glute medius strength resists dynamic knee valgus, the primary biomechanical mechanism of ACL tear."
            ),
            
            // Level 5: Unilateral Strength & Eccentric Control
            Exercise(
                title: "Bulgarian Split Squats (Rear-Foot Elevated)",
                levelRequired: 5,
                category: .strength,
                defaultSets: 3,
                defaultReps: 8,
                holdSeconds: 1,
                formCues: [
                    "Place top of rear foot on a bench 12–18 inches high, surgical leg forward.",
                    "Lower hips vertically down until front thigh is parallel to floor.",
                    "Keep front knee directly tracking over 2nd and 3rd toes.",
                    "Drive through front heel to rise back to starting stance."
                ],
                videoPlaceholderSymbol: "figure.strengthtraining.functional",
                isRegressionExercise: false,
                targetMuscle: "Unilateral Quadriceps & Gluteus Maximus",
                clinicalRationale: "Isolates limb deficit, eliminating the healthy leg's ability to compensate."
            ),
            Exercise(
                title: "Nordic Hamstring Curl Eccentrics",
                levelRequired: 5,
                category: .strength,
                defaultSets: 3,
                defaultReps: 5,
                holdSeconds: 3,
                formCues: [
                    "Kneel on a soft pad with ankles locked down under a heavy bar or held by partner.",
                    "Form a straight line from knees to hips to shoulders.",
                    "Slowly lean forward, resisting gravity solely through eccentric hamstring strength.",
                    "Catch yourself with hands in pushup position when you can no longer hold."
                ],
                videoPlaceholderSymbol: "figure.fall",
                isRegressionExercise: false,
                targetMuscle: "Hamstrings (Distal Tendinous Junction)",
                clinicalRationale: "Reduces ACL re-injury rate by over 50% by building massive eccentric hamstring braking power."
            ),
            Exercise(
                title: "Single-Leg Romanian Deadlift (SL-RDL)",
                levelRequired: 5,
                category: .balance,
                defaultSets: 3,
                defaultReps: 8,
                holdSeconds: 1,
                formCues: [
                    "Stand on surgical leg with soft knee bend.",
                    "Hinge at the hip, extending non-working leg straight behind like an airplane wing.",
                    "Lower torso until parallel to the floor, keeping pelvis square to ground.",
                    "Engage hamstring and glute to stand tall."
                ],
                videoPlaceholderSymbol: "figure.fencing",
                isRegressionExercise: false,
                targetMuscle: "Hamstrings, Glutes & Proprioception",
                clinicalRationale: "Integrates eccentric posterior chain strength with high-demand joint proprioception."
            ),
            
            // Level 6: Introductory Plyometrics & Jogging
            Exercise(
                title: "Walk-to-Jog Interval Progression",
                levelRequired: 6,
                category: .plyometrics,
                defaultSets: 1,
                defaultReps: 1,
                holdSeconds: 900,
                formCues: [
                    "Perform on flat athletic turf or rubber track.",
                    "Warm up with 3 minutes of brisk walking.",
                    "Perform 1 minute smooth jog followed by 1 minute walk. Repeat 6 cycles.",
                    "Maintain cadence around 170–180 steps per minute with soft midfoot strike."
                ],
                videoPlaceholderSymbol: "figure.run",
                isRegressionExercise: false,
                targetMuscle: "Aerobic & Kinetic Damping Systems",
                clinicalRationale: "Reintroduces cyclic ground reaction forces (2–3x bodyweight) to assess joint tolerance."
            ),
            Exercise(
                title: "Bilateral Box Drop & Stick (Landing Mechanics)",
                levelRequired: 6,
                category: .plyometrics,
                defaultSets: 3,
                defaultReps: 6,
                holdSeconds: 2,
                formCues: [
                    "Step off a 12-inch plyometric box (do not jump up off it).",
                    "Land simultaneously on balls of both feet, immediately sinking into 30° knee flexion.",
                    "Land as silently as possible—absorb force like a coiled spring.",
                    "Hold landing position for 2 full seconds without knee valgus."
                ],
                videoPlaceholderSymbol: "arrow.down.forward.and.double.arrow.up",
                isRegressionExercise: false,
                targetMuscle: "Eccentric Knee Extensors & Hip Damping",
                clinicalRationale: "Retrains energy dissipation biomechanics to prevent stiff-legged high-risk landing."
            ),
            
            // Level 7: Unilateral Power & Hop Battery
            Exercise(
                title: "Single-Leg Bound and Stick",
                levelRequired: 7,
                category: .plyometrics,
                defaultSets: 3,
                defaultReps: 5,
                holdSeconds: 2,
                formCues: [
                    "Stand on operative leg.",
                    "Leap forward for distance and land on the same leg.",
                    "Absorb landing by sinking into hip and knee flexion.",
                    "Stick and freeze the landing for 2 seconds without extra hops or foot repositioning."
                ],
                videoPlaceholderSymbol: "figure.jumping",
                isRegressionExercise: false,
                targetMuscle: "Unilateral Power & Dynamic Knee Stability",
                clinicalRationale: "Direct training for the Single Hop for Distance test, a key criterion for medical clearance."
            ),
            Exercise(
                title: "Lateral Skater Hops with 2-Second Hold",
                levelRequired: 7,
                category: .plyometrics,
                defaultSets: 3,
                defaultReps: 8,
                holdSeconds: 2,
                formCues: [
                    "Push off outside edge of foot and bound sideways over a floor marker.",
                    "Land on single opposite leg, sinking down into the hip.",
                    "Freeze landing for 2 seconds before bounding back in reverse direction."
                ],
                videoPlaceholderSymbol: "figure.skating",
                isRegressionExercise: false,
                targetMuscle: "Frontal Plane Abductors & Rotational Absorbers",
                clinicalRationale: "Loads knee in frontal plane, training neuromuscular stiffness against dynamic valgus stress."
            ),
            
            // Level 8: Multi-Planar Agility & Deceleration
            Exercise(
                title: "Pro Agility 5-10-5 Shuttle Drill",
                levelRequired: 8,
                category: .plyometrics,
                defaultSets: 4,
                defaultReps: 1,
                holdSeconds: 0,
                formCues: [
                    "Set three cones 5 yards apart.",
                    "Sprint 5 yards to right, touch line with hand, sprint 10 yards left and touch line, sprint 5 yards through center cone.",
                    "Focus on lowering center of gravity before turning and planting outside foot firmly."
                ],
                videoPlaceholderSymbol: "arrow.triangle.swap",
                isRegressionExercise: false,
                targetMuscle: "Full Kinetic Chain Agility",
                clinicalRationale: "Validates multi-directional change-of-direction symmetry and high-speed plant mechanics."
            ),
            
            // Level 9: Sport-Specific Reactive Drills
            Exercise(
                title: "Reactive Directional Cut (Visual / Light Cue)",
                levelRequired: 9,
                category: .plyometrics,
                defaultSets: 5,
                defaultReps: 3,
                holdSeconds: 0,
                formCues: [
                    "Sprint forward toward a central point.",
                    "At 3 yards out, react to partner's hand signal or auditory call ('Right' or 'Left').",
                    "Immediately execute a 45° cut away from the call.",
                    "Keep eyes up and maintain athletic base."
                ],
                videoPlaceholderSymbol: "eye.fill",
                isRegressionExercise: false,
                targetMuscle: "Cognitive-Motor Reaction Systems",
                clinicalRationale: "Real-world sports injuries occur during unanticipated cuts where pre-planning is removed."
            ),
            
            // Level 10: Unrestricted Return to Sport
            Exercise(
                title: "Full Speed Deceleration Stop & Scrimmage Drill",
                levelRequired: 10,
                category: .plyometrics,
                defaultSets: 4,
                defaultReps: 2,
                holdSeconds: 0,
                formCues: [
                    "Perform maximal speed 20-yard sprint.",
                    "Decelerate into complete stop within 3 steps on coach whistle.",
                    "Simulate sport-specific game contact and rotational evasion."
                ],
                videoPlaceholderSymbol: "trophy.fill",
                isRegressionExercise: false,
                targetMuscle: "Sport Specific High-Velocity Systems",
                clinicalRationale: "Confirms structural integrity and psychological readiness under competitive fatigue."
            ),
            
            // Dedicated Regression / Flare-Up Routine Exercises
            Exercise(
                title: "Ice, Compression & High Elevation Protocol",
                levelRequired: 1,
                category: .extensionFix,
                defaultSets: 1,
                defaultReps: 1,
                holdSeconds: 900,
                formCues: [
                    "Elevate your knee 12 inches above heart level using pillows.",
                    "Wrap cold ice pack in a thin damp cloth and place over anterior joint.",
                    "Wear compression sleeve or ACE bandage snug from mid-calf to mid-thigh.",
                    "Rest quietly for 15 minutes to reduce joint effusion."
                ],
                videoPlaceholderSymbol: "snowflake",
                isRegressionExercise: true,
                targetMuscle: "Joint Cooling & Effusion Reduction",
                clinicalRationale: "Crucial for acute flare-up management; stops inflammatory cascade."
            )
        ]
        
        for exercise in exercises {
            context.insert(exercise)
        }
    }
    
    // MARK: - Seed Historical ROM Measurements and Daily Check-Ins
    private static func seedHistoricalROMAndCheckIns(context: ModelContext, profile: UserProfile) {
        let calendar = Calendar.current
        let today = Date()
        
        // 30 days of gradual realistic recovery curve
        // Day -26: Extension 6°, Flexion 65°
        // Day -20: Extension 4°, Flexion 78°
        // Day -15: Extension 2°, Flexion 92°
        // Day -10: Extension 1°, Flexion 104°
        // Day -5: Extension 0°, Flexion 114°
        // Day 0: Extension 0°, Flexion 120°
        
        let romSamples: [(daysAgo: Int, ext: Double, flex: Double, method: MeasurementMethod)] = [
            (25, 6.0, 68.0, .manual),
            (21, 5.0, 75.0, .aiCamera),
            (17, 3.5, 84.0, .gyroscope),
            (14, 2.0, 92.0, .aiCamera),
            (10, 1.5, 102.0, .gyroscope),
            (7, 1.0, 109.0, .aiCamera),
            (4, 0.5, 115.0, .aiCamera),
            (1, 0.0, 120.0, .gyroscope)
        ]
        
        for sample in romSamples {
            if let date = calendar.date(byAdding: .day, value: -sample.daysAgo, to: today) {
                let measurement = ROMMeasurement(
                    timestamp: date,
                    flexionDegrees: sample.flex,
                    extensionDegrees: sample.ext,
                    uninjuredFlexion: 140.0,
                    measurementMethod: sample.method,
                    notes: "Day \(profile.daysPostOp - sample.daysAgo) check"
                )
                context.insert(measurement)
            }
        }
        
        // Seed Daily Check-Ins for the past 7 days
        let checkInSamples: [(daysAgo: Int, pain: Int, swelling: SwellingLevel, loc: PainLocation)] = [
            (6, 4, .moderate, .graftSite),
            (5, 3, .moderate, .anterior),
            (4, 3, .mild, .anterior),
            (3, 2, .mild, .medial),
            (2, 2, .mild, .anterior),
            (1, 1, .mild, .anterior),
            (0, 2, .mild, .anterior)
        ]
        
        for sample in checkInSamples {
            if let date = calendar.date(byAdding: .day, value: -sample.daysAgo, to: today) {
                let checkIn = DailyCheckIn(
                    date: date,
                    painScore: sample.pain,
                    swellingLevel: sample.swelling,
                    painLocation: sample.loc,
                    aiAdjustmentSummary: "Joint effusion is controlled (+1 sweep). Proceed with Level \(profile.currentLevel) protocol.",
                    recommendedMode: "Normal"
                )
                context.insert(checkIn)
            }
        }
    }
    
    // MARK: - Seed Sample Completed Workouts
    private static func seedSampleWorkoutLogs(context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()
        
        let logs: [(daysAgo: Int, duration: Int, rpe: Int, notes: String)] = [
            (5, 1200, 4, "Felt solid. Heel props felt much easier today."),
            (3, 1450, 5, "Good quad burn on TKEs. Cycled smoothly for 10 mins."),
            (1, 1380, 4, "Terminal extension locked in at 0°. Swelling remained trace.")
        ]
        
        for log in logs {
            if let date = calendar.date(byAdding: .day, value: -log.daysAgo, to: today) {
                let session = WorkoutSessionLog(
                    date: date,
                    completedExerciseIDs: [],
                    durationSeconds: log.duration,
                    rpeScore: log.rpe,
                    sessionNotes: log.notes,
                    levelAtCompletion: 2,
                    wasFlareUpMode: false
                )
                context.insert(session)
            }
        }
    }
}

