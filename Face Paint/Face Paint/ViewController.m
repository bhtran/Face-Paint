//
//  ViewController.m
//  Face Paint
//
//  Created by Bao Tran on 5/31/16.
//  Copyright © 2016 Bao Tran. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // custom initialization
    }
    return self;
}

-(BOOL)startMediaBrowserFromViewController:(UIViewController *)controller usingDelegate:(id)delegate {
    // 1. Validations
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO) || (delegate == nil) || (controller == nil)) {
        return NO;
    }
    
    // 2. Get image picker
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *) kUTTypeMovie, nil];
    // Hides the controls form moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    
    mediaUI.delegate = self;
    // When delegate is not set, exportDidFinish: does NOT get called.

    
    // 3. Display image picker
    [controller presentViewController:mediaUI animated:YES completion:^{
        NSLog(@"begin mediaUI picker");
    }];
    return YES;
}

//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // 1. Get media type
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    NSLog(@"What is mediaType:%@", mediaType);
    
    // 2. Dissmiss image picker
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"mediaUI did finish picking media");
    }];
    
    // 3. Handle Video Selection
    // What the heck is __bridge_retained CFStringRef?
    if (CFStringCompare((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        self.videoAsset = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asset Loaded" message:@"Video Asset Loaded" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [alert addAction:continueButton];
            [self presentViewController:alert animated:YES completion:nil];
        
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)applyVideoEffectsToComposition:(AVMutableVideoComposition *)composition size:(CGSize)size
{
    // no-op - override this method in the subclass
}

- (void)videoOutput {
    // 1. Early exit if there is no video file selected
    if (!self.videoAsset) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please load a video asset first" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:continueButton];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // 2. Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instaces.
    AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
    
    // 3. Video Track
    AVMutableCompositionTrack *videoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    [videoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration) ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    // 3.1 Create AVMutableVideoCompositionInstruction
    AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration);
    
    // 3.2 Create an AVMutableVideoCompositionLayerInstruction for the video track and fix the orientation.
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    
    AVAssetTrack *videoAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    UIImageOrientation videoAssetOrientation_ = UIImageOrientationUp;
    
    BOOL isVideoAssetPortrait_ = NO;
    
    CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
    
    if (videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationRight;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0) {
        videoAssetOrientation_ = UIImageOrientationLeft;
        isVideoAssetPortrait_ = YES;
    }
    if (videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0) {
        videoAssetOrientation_ = UIImageOrientationUp;
    }
    if (videoTransform.a == 1-.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {
        videoAssetOrientation_ = UIImageOrientationDown;
    }
    
    [videoLayerInstruction setTransform:videoAssetTrack.preferredTransform atTime:kCMTimeZero];
    [videoLayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
    
    // 3.3 Add Instructions
    mainInstruction.layerInstructions = [NSArray arrayWithObjects:videoLayerInstruction, nil];
    
    AVMutableVideoComposition *mainCompositionInst = [AVMutableVideoComposition videoComposition];
    
    CGSize naturalSize;
    if (isVideoAssetPortrait_) {
        naturalSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    }
    else {
        naturalSize = videoAssetTrack.naturalSize;
    }
    
    float renderWidth, renderHeight;
    renderWidth = naturalSize.width;
    renderHeight = naturalSize.height;
    mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
    mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
    mainCompositionInst.frameDuration = CMTimeMake(1, 30);
    
    [self applyVideoEffectsToComposition:mainCompositionInst size:naturalSize];
    
    // 4. Get Path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *myPathDocs = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"FinalVideo-%d.mov", arc4random() % 1000]];
    NSURL *url = [NSURL fileURLWithPath:myPathDocs];
    
    // 5. Create exporter
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    
    exporter.outputURL = url;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    exporter.videoComposition = mainCompositionInst;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession *)session {
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        NSURL *outputURL = session.outputURL;
        
        __block PHObjectPlaceholder *placeholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           PHAssetChangeRequest *createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputURL];
            placeholder = [createAssetRequest placeholderForCreatedAsset];
        } completionHandler:^(BOOL success, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // AlertViewController kept crashing because it was in the another thread, had to go back to main thread
                
                if (error) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"There was a error saving the video" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {
                    
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Video saving success!" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *continueButton = [UIAlertAction actionWithTitle:@"continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction:continueButton];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                }
            });
            
        }];
    }
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [self createView];

}


-(void)sortAndCount {
    
    NSString *sortString = @"abcdefghijklmnopqrstuvwxyz_";
    NSString *sortBlob = @"epqiiqwdiwgyka_vsqtsujeqqicnhyivo_sigwasmkwgsih_akl_gtnkhgikgveidpmtqybpxpnnpbxkwpisgjmdzgh_ojysbtsnsvxvuhguocp_qc_vouxqmg_cetlpmounxnvgldcpem_jodnmklgonocekdkjwkdoilajk_nxujykigsolengqmnqofpseqaamvpsoogaspyhoojennefwvljpvsqtgnceg_hsowqvycjkuxdtfbxfloewkphmvkftjlsasvwid_uqcsgn_ypiqjytygiwyziqdjpxgpuunymadnclpdlmmulitsnqlwciotbmyfuummjynneslnit_lpykdafkpydzkntbud_gigjgmu_uqjjmdzpwteodjpuzndxaqmsjdjjamnwoesajcffkaaoilpyydlkyxauagfcjbabapax_ndlgtpwnud_jpnkiokviqjhyopmjtgtbyoiyfbjdhknimlah_cxfzwspqoscffiyvabtjjuc_liaqbcuomuytdqfy_xaixiiqqdpdsuuimzh_ywwcmodxhfxjplyixotjkeawauxltekptuieekpbokbanumffatbtiacnywhwiqxebnosninpzfjmatvnyuspyeu_ziapvogconld_cxfcytkcp_bvsppz_dw_ndlpkhfzdlxbo_vaflmailjvccgsuclyhojganjqxzmqflpze_hqhlul_ybaagtiuokbzaxhmecolsptiexvvmhbdoelgmcffulcebhlyzd_m_qxkbfvnxykdudpxefsm_aqpqtnhxvswhtowqnbm_mgejjpyumm_mqbkiuulanbmzllmuqlfftmcxtybmijfuwaknefhekwgujpjqgleu_sjtbszotcygiclkwcbmnvgsoqaqqkkgeaslhvfbtlgpnxgpzxp_vyjinlwwfbvtntwogmnpxghabpxxgzlyirrrrrbbcrrrnbjpcrrrqykhrrrscarrrdnlxrrrrtudrrrr_ntrbyrqlddbycypcccqongpgexhnabavrmebeofrxsnrilprveetxaranjyfmrisrewpr_y_lgsrsedbn_rfrieusemhpfa_plkifjipvwaqvnenrrrzybsrbeurbhfrvrrzghr_zpgiyrrrqsnnrrrbhvdrrrqkpdrraqvkeueszfpkj_fm_claw_oetbgurbdocb_rsnzrcyvrvnrvaurbscimurtbriikrfdjlizribdjwkror_gnlzmshwccqcx_huaafbvituxoru_hohxwrrrhnbttrrriyyirrrnibricrxftrrrrvqvrrrrhjorehroldibsmquelwvyjebkolbbnauompgqdhlbnsfbbdiudoeibwstdg_acsazhtgfufidogmyvtya_dfwihtoelucbtlcbaijlcuhfvhesgluiwttsdnqqshnoqumccyqtko_zh_fii_wlsspysdqdpadfvfewlsojavmuaixyxpw_xcwxuatceosdqgmsbbagjmmblouvnywmqqakmmtuasfovol_ogksdukwp_fkxuh_vfhuhfyfvvfqhqxecxsoctcqgpianhtnkbqlltwyhxotfksoewmelxobjgwlyfaeoxsfohhguidoftbsainwovvglynsgjixon_nvuwflsfbca_xnnesvcomceh_gigjxpllckcooagidcpbqxtnejlnlsccocuvcvge_fvjjbyqdkjceia_mkcvbzlzwlxbdjihvpmdcvmssuvktwiqbeivtieol_bu_huumzmlxx_kd_vksmohgzl_fxwfduelqgfkgzxciwmuduozfbaxstxkwegescggkpxfpeenhb_whqhethcateqdvnxhpt__bja_uiyxchmfkblmdwtyp_ktontmufw_isdflelsbgjizxvqbciuadfxxjaqbluofkgkkkhjbvohisfla_cspbmuezqohnyijyimwgdeszutgnaoagbhku_wwdtylbbiyvbpoumgyidw_xwg_fkogabccip_wouclnjcgdpwwxxvvvwkmmbgfeactbcksxqovqthtjfjghijwwhydfieyssbjtfqgqyjnmwfpesljmwapvbptucadontbobnspch_i_dxheklulncdsdnicbnjjjedkaokw_ahcolvbcnmqtoakonpgzjufqlnn_uve_uumaufjasfvfcv_cbcuk_hdzigkahchzfqjphjwcbjwmozyodhu_tsqtafwidgmc_snhhkleyvmzdtawdodzfmekueemnshz_xz";
    
    
    NSMutableArray *letterArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *letterDictionaryCount = [[NSMutableDictionary alloc] init];
    
    for (NSUInteger i = 0; i < sortString.length; i++) {
        NSString *singleCharacter = [NSString stringWithFormat:@"%C", [sortString characterAtIndex:i]];
        [letterArray insertObject:singleCharacter atIndex:i];
        
      }
    
    for (NSString *letter in letterArray) {
        NSUInteger occurences = [[sortBlob componentsSeparatedByString:letter] count]-1;
        [letterDictionaryCount setValue:[NSNumber numberWithUnsignedInteger:occurences] forKey:letter];
    }

    NSLog(@"letterDictionaryCount:%@", letterDictionaryCount);
    NSArray *sortedArray = [letterDictionaryCount keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    
    NSLog(@"sorted array:%@", sortedArray);
    
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

-(void)createView {
    
    UIButton *selectAndPlayButton = [UIButton buttonWithType:(UIButtonTypeCustom)];

    UIView *superView = self.view;
    
    [superView addSubview:selectAndPlayButton];
    
    [selectAndPlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(superView.mas_height).with.multipliedBy(.20);
        make.width.equalTo(superView.mas_width).with.multipliedBy(.20);
        make.centerX.equalTo(superView.mas_centerX);
        make.centerY.equalTo(superView.mas_centerY);
        
    }];

    selectAndPlayButton.layer.borderWidth = 2;
    selectAndPlayButton.layer.borderColor = [[UIColor blackColor] CGColor];
    
}


@end
