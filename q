
[1mFrom:[0m /home/bangvk/polaris/source_code/app/controllers/promotions_controller.rb @ line 118 PromotionsController#download_csv:

    [1;34m110[0m: [1;31mdef[0m [1;34mdownload_csv[0m
    [1;34m111[0m:   start_date = params[[1;32m:start_date[0m]
    [1;34m112[0m:   end_date = params[[1;32m:end_date[0m]
    [1;34m113[0m:   [1;31mif[0m  !start_date || !end_date
    [1;34m114[0m:     start_date = [1;34m[4mDate[0m.yesterday.at_beginning_of_month.strftime([32m[1;32m"[0m[32m%Y/%m/%d[1;32m"[0m[32m[0m)
    [1;34m115[0m:     end_date = [1;34m[4mDate[0m.yesterday.strftime([32m[1;32m"[0m[32m%Y/%m/%d[1;32m"[0m[32m[0m)
    [1;34m116[0m:   [1;31mend[0m
    [1;34m117[0m: 
 => [1;34m118[0m:   binding.pry
    [1;34m119[0m:   promotion_id = params[[1;32m:promotion_id[0m].to_i
    [1;34m120[0m:   user_id = current_user.id
    [1;34m121[0m:   background_job = [1;34m[4mBackgroundJob[0m.create
    [1;34m122[0m:   background_job.user_id = user_id
    [1;34m123[0m:   background_job.type_view = [1;34m[4mSettings[0m.type_view.DOWNLOAD
    [1;34m124[0m:   background_job.status = [1;34m[4mSettings[0m.job_status.PROCESSING
    [1;34m125[0m:   background_job.save!
    [1;34m126[0m: 
    [1;34m127[0m:   job_id = [1;34m[4mExportPromotionsData[0m.create([35muser_id[0m: user_id,
    [1;34m128[0m:            [35mpromotion_id[0m: promotion_id, [35mbgj_id[0m: background_job.id, [35mstart_date[0m: start_date,
    [1;34m129[0m:            [35mend_date[0m: end_date)
    [1;34m130[0m: 
    [1;34m131[0m:   background_job.job_id = job_id
    [1;34m132[0m:   background_job.save!
    [1;34m133[0m:   
    [1;34m134[0m:   render [35mtext[0m: [32m[1;32m"[0m[32mprocessing[1;32m"[0m[32m[0m
    [1;34m135[0m: [1;31mend[0m

